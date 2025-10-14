import { LightningElement, track, wire, api } from 'lwc';
import getCampaignVideos from '@salesforce/apex/AdCampaignController.getCampaignVideos';
import logConversation from '@salesforce/apex/FluentConversationController.logConversation';
import getOrgDomain from '@salesforce/apex/AgentforceController.getOrgDomain';
import initializeAgentSession from '@salesforce/apex/AgentforceController.initializeAgentSession';
import getAgentRecommendation from '@salesforce/apex/AgentforceController.getAgentRecommendation';
import endAgentSession from '@salesforce/apex/AgentforceController.endAgentSession';
import consumer_Key_label from '@salesforce/label/c.Consumer_Key';
import consumer_Secret_label from '@salesforce/label/c.Consumer_Secret';
import agent_Id_label from '@salesforce/label/c.Agent_Id';

export default class ConversationalAdPlayer extends LightningElement {
    @api recordId;
    @track videos = [];
    @track currentSlideIndex = 0;
    @track showInteraction = false;
    @track isRecording = false;
    @track liveTranscript = '';
    @track agentResponse = '';
    @track latestQuestion = '';
    @track currentMessage = '';
    @track currentSuggestions = [];
    @track clickedSuggestions = [];
    @track errorMessage = '';
    @track isTyping = false;
    @track isCentered = false;
    
    // Drag and drop properties
    isDragging = false;
    dragStartX = 0;
    dragStartY = 0;
    initialX = 0;
    initialY = 0;
    currentX = 0;
    currentY = 0;
    
    // Speech recognition
    recognition;
    speechRecognitionInitialized = false;
    
    // Session tracking for conversation logging
    sessionId = null;
    currentInteractionType = null; // Track whether current interaction is 'Voice' or 'Text'
    
    // AgentforceController integration
    @track consumerKey = consumer_Key_label;
    @track consumerSecret = consumer_Secret_label;
    @track agentId = agent_Id_label;
    @track orgDomain = '';
    @track agentSessionId = null; // Separate from conversation sessionId
    
    error;

    connectedCallback() {
        // Generate unique session ID for conversation tracking FIRST
        // This must happen before singleton check to ensure it's always available
        this.sessionId = this.generateSessionId();
        console.log('📊 Session ID generated:', this.sessionId);
        
        // Generate unique ID for this instance
        this.instanceId = `player-${Math.random().toString(36).substr(2, 9)}`;
        console.log('🎬 ConversationalAdPlayer: Component connected! Instance:', this.instanceId);
        console.log('🎬 recordId:', this.recordId);
        
        // Check if another instance already exists - hide this one if so
        const existingPlayer = document.querySelector('c-conversational-ad-player:not([data-instance="' + this.instanceId + '"])');
        if (existingPlayer) {
            console.log('🎬 Another player instance already exists, hiding this one');
            this.template.host.style.display = 'none';
            return;
        }
        
        // Mark this instance
        this.template.host.setAttribute('data-instance', this.instanceId);
        
        // Initialize org domain and credentials
        this.initializeOrgDomain();
        
        // Component initialization
        // CLEAR any saved position that might be off-screen
        localStorage.removeItem('videoCarouselPosition');
        
        // Reset position to default (0, 0) which uses CSS defaults
        this.currentX = 0;
        this.currentY = 0;
        
        console.log('🎬 Component initialization complete');
        console.log('🎬 Position reset to:', this.currentX, this.currentY);
    }

    async initializeOrgDomain() {
        try {
            this.orgDomain = await getOrgDomain();
            console.log('Org Domain:', this.orgDomain);
        } catch (error) {
            console.error('Error getting org domain:', error);
        }
    }


    async initializeAgentSession() {
        try {
            console.log('Initializing agent session...');
            
            // Get the current video's product code
            const currentVideo = this.videos[this.currentSlideIndex];
            const productCode = currentVideo?.Product_Code__c || null;
            
            console.log('@@Current video Product Code:', productCode);
            console.log('@@this.recordId', this.recordId);

            console.log('Current video details:', {
                Id: currentVideo?.Id,
                Product_Name__c: currentVideo?.Product_Name__c,
                Product_Code__c: currentVideo?.Product_Code__c
            });
            
            this.agentSessionId = await initializeAgentSession({
                agentId: this.agentId,
                consumerKey: this.consumerKey,
                consumerSecret: this.consumerSecret,
                campaignId: this.recordId,
                productCode : productCode
            });
            console.log('Agent session initialized with ID:', this.agentSessionId);
            console.log('Session initialized for Product Code:', productCode);
        } catch (error) {
            console.error('Error initializing agent session:', error);
            throw error;
        }
    }

    async endAgentSession() {
        if (this.agentSessionId) {
            try {
                console.log('Ending agent session:', this.agentSessionId);
                await endAgentSession({
                    sessionId: this.agentSessionId,
                    consumerKey: this.consumerKey,
                    consumerSecret: this.consumerSecret
                });
                console.log('Agent session ended successfully');
            } catch (error) {
                console.error('Error ending agent session:', error);
            } finally {
                this.agentSessionId = null;
            }
        }
    }
    
    initializeSpeechRecognition() {
        console.log('🎤 Initializing Speech Recognition...');
        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;

        if (!SpeechRecognition) {
            console.error('🎤 Speech Recognition NOT available');
            this.errorMessage = 'Voice input is not supported in this browser. Please use text input.';
            return;
        }

        console.log('🎤 Speech Recognition API found:', SpeechRecognition);
        try {
            this.recognition = new SpeechRecognition();
            console.log('🎤 Speech Recognition instance created successfully:', this.recognition);
            this.recognition.continuous = true;
            this.recognition.interimResults = true;
            this.recognition.lang = 'en-US';

            this.recognition.onstart = () => {
                this.isRecording = true;
                this.liveTranscript = '';
                this.errorMessage = '';
            };

            this.recognition.onresult = (event) => {
                let interimTranscript = '';
                let finalTranscript = '';

                for (let i = event.resultIndex; i < event.results.length; ++i) {
                    const transcript = event.results[i][0].transcript;
                    if (event.results[i].isFinal) {
                        finalTranscript += transcript;
                    } else {
                        interimTranscript += transcript;
                    }
                }

                this.liveTranscript = interimTranscript || finalTranscript;
                if (finalTranscript) {
                    this.latestQuestion = finalTranscript;
                    this.handleVoiceQuestion(finalTranscript);
                    this.recognition.stop();
                }
            };

            this.recognition.onerror = (event) => {
                console.error('Speech recognition error:', event.error);
                this.isRecording = false;
                if (event.error === 'not-allowed') {
                    this.errorMessage = 'Microphone access denied. Please use text input or enable microphone permissions.';
                } else if (event.error !== 'aborted') {
                    this.errorMessage = 'Voice recognition error. Please try again or use text input.';
                }
            };

            this.recognition.onend = () => {
                this.isRecording = false;
            };
        } catch (e) {
            console.error('Speech recognition init failed:', e);
            this.errorMessage = 'Voice input could not be initialized. Please use text input.';
        }
    }
    
    renderedCallback() {
        console.log('🎬 Component rendered');
        console.log('🎬 Videos length:', this.videos ? this.videos.length : 0);
        
        // Initialize speech recognition once after render
        if (!this.speechRecognitionInitialized) {
            this.speechRecognitionInitialized = true;
            this.initializeSpeechRecognition();
        }
        
        // Debug: Log component position and visibility
        const host = this.template.host;
        const container = this.template.querySelector('.carousel-container');
        const wrapper = this.template.querySelector('.component-wrapper');
        
        console.log('🎬 Host element:', host);
        console.log('🎬 Host computed style:', window.getComputedStyle(host));
        console.log('🎬 Host position:', {
            position: window.getComputedStyle(host).position,
            display: window.getComputedStyle(host).display,
            visibility: window.getComputedStyle(host).visibility,
            opacity: window.getComputedStyle(host).opacity,
            zIndex: window.getComputedStyle(host).zIndex,
            top: window.getComputedStyle(host).top,
            left: window.getComputedStyle(host).left,
            right: window.getComputedStyle(host).right,
            bottom: window.getComputedStyle(host).bottom,
            width: window.getComputedStyle(host).width,
            height: window.getComputedStyle(host).height
        });
        
        if (container) {
            console.log('🎬 Container found:', container);
            console.log('🎬 Container dimensions:', {
                width: container.offsetWidth,
                height: container.offsetHeight,
                display: window.getComputedStyle(container).display
            });
        } else {
            console.log('🎬 ❌ Container NOT found');
        }
        
        if (wrapper) {
            console.log('🎬 Wrapper found:', wrapper);
        } else {
            console.log('🎬 ❌ Wrapper NOT found');
        }
        
        // Bind drag events after render
        if (container && !this.dragEventsAdded) {
            this.dragEventsAdded = true;
            this.addDragListeners();
            // Apply saved position if exists
            if (this.currentX !== 0 || this.currentY !== 0) {
                this.updatePosition();
            }
        }
        
        // Update slide position for carousel
        setTimeout(() => {
            if (this.videos && this.videos.length > 0) {
                const slides = this.template.querySelectorAll('.carousel-slide');
                if (slides.length > 0) {
                    this.updateSlidePosition();
                }
            }
        }, 100);
    }
    
    setupDragFunctionality() {
        if (this.dragSetupComplete) {
            console.log('=== DRAG: Already setup ===');
            return;
        }
        
        console.log('=== DRAG: Setting up drag functionality ===');
        const container = this.template.querySelector('.carousel-container');
        
        if (!container) {
            console.log('=== DRAG: Container not found, will retry ===');
            setTimeout(() => this.setupDragFunctionality(), 200);
            return;
        }
        
        console.log('=== DRAG: Container found, adding listeners ===');
        
        // Bind handlers with proper context
        this._boundDragStart = this.handleDragStart.bind(this);
        this._boundDrag = this.handleDrag.bind(this);
        this._boundDragEnd = this.handleDragEnd.bind(this);
        this._boundTouchStart = this.handleTouchStart.bind(this);
        this._boundTouchMove = this.handleTouchMove.bind(this);
        this._boundTouchEnd = this.handleDragEnd.bind(this);
        
        // Add event listeners
        container.addEventListener('mousedown', this._boundDragStart, { passive: false });
        console.log('=== DRAG: Mouse listeners added ===');
        
        // Touch events for mobile
        container.addEventListener('touchstart', this._boundTouchStart, { passive: false });
        
        this.dragSetupComplete = true;
    }
    
    addDragListeners() {
        // Legacy method - now using setupDragFunctionality
        this.setupDragFunctionality();
    }
    
    disconnectedCallback() {
        // Clean up event listeners
        const container = this.template.querySelector('.carousel-container');
        if (container) {
            container.removeEventListener('mousedown', this._boundDragStart);
            container.removeEventListener('touchstart', this._boundTouchStart);
        }
        
        if (this._boundDrag) {
            document.removeEventListener('mousemove', this._boundDrag);
            document.removeEventListener('mouseup', this._boundDragEnd);
            document.removeEventListener('touchmove', this._boundTouchMove);
            document.removeEventListener('touchend', this._boundTouchEnd);
        }
        
        // Clean up agent session when component is destroyed
        this.endAgentSession();
    }
    
    handleDragStart(e) {
        console.log('Drag: Mouse down detected', e.target);
        
        // Don't allow dragging when centered/enlarged
        if (this.isCentered) {
            console.log('Drag: Ignoring - component is centered');
            return;
        }
        
        // Only prevent drag on buttons and chat panel (allow dragging on video)
        if (e.target.closest('button') || 
            e.target.closest('.chat-panel') || 
            e.target.closest('.chat-toggle-button') ||
            e.target.closest('.carousel-button')) {
            console.log('Drag: Ignoring interactive element');
            return;
        }
        
        console.log('Drag: Starting drag');
        this.isDragging = true;
        this.dragStartX = e.clientX;
        this.dragStartY = e.clientY;
        this.initialX = this.currentX;
        this.initialY = this.currentY;
        
        // Add document-level listeners for drag
        document.addEventListener('mousemove', this._boundDrag);
        document.addEventListener('mouseup', this._boundDragEnd);
        
        // Add dragging class for visual feedback
        const container = this.template.querySelector('.carousel-container');
        if (container) {
            container.classList.add('dragging');
            console.log('Drag: Added dragging class');
        }
        
        e.preventDefault();
    }
    
    handleTouchStart(e) {
        // Don't allow dragging when centered/enlarged
        if (this.isCentered) {
            return;
        }
        
        // Only prevent drag on buttons and chat panel (allow dragging on video)
        if (e.target.closest('button') || 
            e.target.closest('.chat-panel') || 
            e.target.closest('.chat-toggle-button') ||
            e.target.closest('.carousel-button')) {
            return;
        }
        
        const touch = e.touches[0];
        this.isDragging = true;
        this.dragStartX = touch.clientX;
        this.dragStartY = touch.clientY;
        this.initialX = this.currentX;
        this.initialY = this.currentY;
        
        // Add document-level listeners for touch drag
        document.addEventListener('touchmove', this._boundTouchMove);
        document.addEventListener('touchend', this._boundTouchEnd);
        
        const container = this.template.querySelector('.carousel-container');
        if (container) {
            container.classList.add('dragging');
        }
    }
    
    handleDrag(e) {
        if (!this.isDragging) return;
        
        e.preventDefault();
        const deltaX = e.clientX - this.dragStartX;
        const deltaY = e.clientY - this.dragStartY;
        
        this.currentX = this.initialX + deltaX;
        this.currentY = this.initialY + deltaY;
        
        console.log('Drag: Moving to', this.currentX, this.currentY);
        this.updatePosition();
    }
    
    handleTouchMove(e) {
        if (!this.isDragging) return;
        
        const touch = e.touches[0];
        const deltaX = touch.clientX - this.dragStartX;
        const deltaY = touch.clientY - this.dragStartY;
        
        this.currentX = this.initialX + deltaX;
        this.currentY = this.initialY + deltaY;
        
        this.updatePosition();
    }
    
    handleDragEnd() {
        if (!this.isDragging) return;
        
        this.isDragging = false;
        
        // Remove document-level listeners
        document.removeEventListener('mousemove', this._boundDrag);
        document.removeEventListener('mouseup', this._boundDragEnd);
        document.removeEventListener('touchmove', this._boundTouchMove);
        document.removeEventListener('touchend', this._boundTouchEnd);
        
        const container = this.template.querySelector('.carousel-container');
        if (container) {
            container.classList.remove('dragging');
        }
        
        // Save position to localStorage
        localStorage.setItem('videoCarouselPosition', JSON.stringify({
            x: this.currentX,
            y: this.currentY
        }));
    }
    
    updatePosition() {
        const component = this.template.host;
        
        // Calculate position based on drag
        // Start from bottom-right (default position)
        const bottom = 20 - this.currentY;
        const right = 20 - this.currentX;
        
        component.style.transform = `translate(${this.currentX}px, ${this.currentY}px)`;
    }

    // The @wire service is now the single source of truth for your data.
    @wire(getCampaignVideos, { campaignId: '$recordId' })
    wiredVideos({ error, data }) {
        console.log('🎬 @wire called - recordId:', this.recordId);
        console.log('🎬 Data received:', data ? data.length + ' videos' : 'null');
        console.log('🎬 Error:', error);
        
        if (data) {
            console.log('🎬 ✅ Videos loaded successfully:', data);
            this.videos = data.map(video => {
                const isYouTube = video.Video_Source_Type__c === 'YouTube';
                const isStaticResource = video.Video_Source_Type__c === 'Static Resource';
                
                // Conditionally set the videoUrl
                let videoUrl;
                if (isYouTube) {
                    videoUrl = `https://www.youtube.com/embed/${video.Video_Id__c}?enablejsapi=1`;
                } else if (isStaticResource) {
                    if (video.Video_URL__c && video.Video_URL__c.startsWith('/apex/')) {
                        const resourceName = video.Video_URL__c.replace('/apex/', '');
                        const currentOrigin = window.location.origin;
                        let lightningDomain;
                        if (currentOrigin.includes('.live-preview.salesforce-experience.com')) {
                            lightningDomain = currentOrigin.replace('.live-preview.salesforce-experience.com', '.lightning.force.com');
                        } else if (currentOrigin.includes('.my.site.com')) {
                            lightningDomain = currentOrigin.replace('.my.site.com', '.lightning.force.com');
                        } else if (currentOrigin.includes('.lightning.force.com')) {
                            lightningDomain = currentOrigin;
                        } else {
                            lightningDomain = currentOrigin;
                        }
                        videoUrl = `${lightningDomain}//resource/${resourceName}`;
                    } else {
                        videoUrl = video.Video_URL__c;
                    }
                } else {
                    // Handle null Video_Source_Type__c - treat as direct URL
                    videoUrl = video.Video_URL__c;
                }

                // Return a new object for the template with our processed data
                return {
                    // Spread operator copies all original fields from the Apex result
                    ...video,
                id: video.Id,
                    // Add our new properties for the template
                    isYouTube: isYouTube,
                    videoUrl: videoUrl
                };
            });
            this.error = undefined;
            
            // Force carousel positioning after videos are loaded
            setTimeout(() => {
                this.updateSlidePosition();
                // Setup drag after DOM is ready
                this.setupDragFunctionality();
            }, 100);
        } else if (error) {
            // Handle any errors
            console.error('🎬 ❌ Error fetching videos:', error);
            console.error('🎬 Error details:', JSON.stringify(error, null, 2));
            this.error = error;
            this.videos = [];
        } else {
            console.log('🎬 ⚠️ No data and no error - waiting for data');
        }
    }


    goToNextSlide() {
        if (this.videos.length === 0) return;
        this.currentSlideIndex = (this.currentSlideIndex + 1) % this.videos.length;
        const slides = this.template.querySelectorAll('.carousel-slide');
        if (slides.length > 0) {
            this.updateSlidePosition();
        }
        setTimeout(() => {
            const slides = this.template.querySelectorAll('.carousel-slide');
            if (slides.length > 0) {
                this.updateSlidePosition();
            }
        }, 50);
        // Clear state and update suggestions when changing videos
        console.log('goToNextSlide - Resetting state for new video');
        this.endAgentSession(); // End current agent session
        this.latestQuestion = '';
        this.agentResponse = '';
        this.clickedSuggestions = [];
        this.currentMessage = '';
        this.errorMessage = '';
        this.showInteraction = false;
        this.isTyping = false;
        // Stop any ongoing recording
        if (this.isRecording && this.recognition) {
            this.recognition.stop();
        }
        this.isRecording = false;
        this.liveTranscript = '';
        // Keep the window centered if it was centered before
        // this.isCentered = false;
        // this.restoreWindow();
        this.loadCurrentSuggestions();
    }

    goToPreviousSlide() {
        if (this.videos.length === 0) return;
        this.currentSlideIndex = (this.currentSlideIndex - 1 + this.videos.length) % this.videos.length;
        const slides = this.template.querySelectorAll('.carousel-slide');
        if (slides.length > 0) {
            this.updateSlidePosition();
        }
        setTimeout(() => {
            const slides = this.template.querySelectorAll('.carousel-slide');
            if (slides.length > 0) {
                this.updateSlidePosition();
            }
        }, 50);
        // Clear state and update suggestions when changing videos
        console.log('goToPreviousSlide - Resetting state for new video');
        this.endAgentSession(); // End current agent session
        this.latestQuestion = '';
        this.agentResponse = '';
        this.clickedSuggestions = [];
        this.currentMessage = '';
        this.errorMessage = '';
        this.showInteraction = false;
        this.isTyping = false;
        // Stop any ongoing recording
        if (this.isRecording && this.recognition) {
            this.recognition.stop();
        }
        this.isRecording = false;
        this.liveTranscript = '';
        // Keep the window centered if it was centered before
        // this.isCentered = false;
        // this.restoreWindow();
        this.loadCurrentSuggestions();
    }

    updateSlidePosition() {
        const track = this.template.querySelector('.carousel-track');
        const slides = this.template.querySelectorAll('.carousel-slide');
        
        if (!track || slides.length === 0 || this.videos.length === 0) {
            return;
        }
    
        if (track && slides.length > 0) {
            const slideWidth = slides[0].clientWidth;
            let actualWidth = slideWidth;
            if (actualWidth === 0) {
                const container = this.template.querySelector('.carousel-container');
                actualWidth = container ? container.clientWidth : 720;
            }
            
            const translateX = -this.currentSlideIndex * actualWidth;
            track.style.transform = `translateX(${translateX}px)`;
        }
    }

    handleVideoError(event) {
        // Handle video error if needed
    }
    
    handleVideoLoadStart(event) {
        // Handle video load start if needed
    }

    // Voice Recognition Methods
    startVoiceInput() {
        console.log('Voice button clicked');
        
        // Check if we're in a sandboxed iframe (Salesforce Experience Site)
        if (window.self !== window.top) {
            console.log('Running in sandboxed iframe - using fallback approach');
            this.showFallbackDialog();
            return;
        }
        
        if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
            console.log('Speech recognition supported');
            const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
            const recognition = new SpeechRecognition();
            
            recognition.continuous = false;
            recognition.interimResults = false;
            recognition.lang = 'en-US';
            
            this.isListening = true;
            console.log('Starting voice recognition...');
            
            recognition.onstart = () => {
                console.log('Voice recognition started');
            };
            
            recognition.onresult = (event) => {
                console.log('Voice recognition result:', event);
                const transcript = event.results[0][0].transcript;
                console.log('Transcript:', transcript);
                this.processVoiceQuery(transcript);
            };
            
            recognition.onerror = (event) => {
                console.error('Voice recognition error:', event.error);
                this.isListening = false;
                
                if (event.error === 'not-allowed') {
                    this.showPermissionDialog();
                } else {
                    this.showFallbackDialog();
                }
            };
            
            recognition.onend = () => {
                console.log('Voice recognition ended');
                this.isListening = false;
            };
            
            try {
                recognition.start();
            } catch (error) {
                console.error('Error starting recognition:', error);
                this.isListening = false;
                this.showFallbackDialog();
            }
        } else {
            console.log('Speech recognition not supported');
            this.showFallbackDialog();
        }
    }

    showPermissionDialog() {
        this.agentResponse = 'Microphone permission is required for voice interaction. Please allow microphone access and try again.';
        this.showResponse = true;
        setTimeout(() => {
            this.showResponse = false;
        }, 8000);
    }

    showFallbackDialog() {
        // Show custom text input modal
        this.showTextInput = true;
        this.textInputValue = '';
    }

    handleTextInputChange(event) {
        this.textInputValue = event.target.value;
    }

    handleTextInputSubmit() {
        if (this.textInputValue && this.textInputValue.trim()) {
            this.processVoiceQuery(this.textInputValue.trim());
            this.showTextInput = false;
            this.textInputValue = '';
        }
    }

    handleTextInputCancel() {
        this.showTextInput = false;
        this.textInputValue = '';
    }

    // Voice & Text Input Methods
    handleTapToAsk() {
        // Show interaction panel and center/enlarge video
        this.showInteraction = true;
        this.isCentered = true;
        this.centerAndEnlargeWindow();
        
        // Load suggestions if not already loaded
        if (this.currentSuggestions.length === 0) {
            this.loadCurrentSuggestions();
        }
    }
    
    handleVoiceToggle() {
        console.log('🎤 handleVoiceToggle called. isRecording:', this.isRecording, 'recognition:', this.recognition);
        
        if (this.isRecording) {
            // Stop recording
            if (this.recognition) {
                console.log('🎤 Stopping recognition...');
                this.recognition.stop();
            }
        } else {
            // Clear previous conversation when starting new voice input
            this.latestQuestion = '';
            this.agentResponse = '';
            this.isTyping = false;
            this.errorMessage = '';
            this.liveTranscript = '';
            
            // Start recording
            if (this.recognition) {
                console.log('🎤 Starting recognition...');
                try {
                    this.recognition.start();
                    console.log('🎤 Recognition start() called successfully');
                } catch (error) {
                    console.error('🎤 Error starting recognition:', error);
                    this.errorMessage = 'Voice recognition not available. Please use text input.';
                    // Show error for a few seconds then auto-hide
                    setTimeout(() => {
                        if (this.errorMessage === 'Voice recognition not available. Please use text input.') {
                            this.errorMessage = '';
                        }
                    }, 3000);
                }
            } else {
                // Voice recognition not supported
                console.error('🎤 Recognition object is null/undefined');
                this.errorMessage = 'Voice recognition not available. Please use text input.';
                // Show error for a few seconds then auto-hide
                setTimeout(() => {
                    if (this.errorMessage === 'Voice recognition not available. Please use text input.') {
                        this.errorMessage = '';
                    }
                }, 3000);
            }
        }
    }
    
    centerAndEnlargeWindow() {
        const component = this.template.host;
        component.classList.add('centered');
        component.classList.add('enlarged');
    }
    
    restoreWindow() {
        const component = this.template.host;
        component.classList.remove('centered');
        component.classList.remove('enlarged');
    }
    
    handleVoiceQuestion(question) {
        // Mark this as a voice interaction
        this.currentInteractionType = 'Voice';
        // Process the voice question
        this.processQuestion(question);
    }
    
    handleCloseClick(event) {
        // Close the interaction panel and restore window
        event.stopPropagation();
        event.preventDefault();
        this.showInteraction = false;
        this.isCentered = false;
        this.restoreWindow();
        
        // Clear chat messages/history when closing
        console.log('handleCloseClick - Clearing chat messages');
        
        // End agent session when closing
        this.endAgentSession();
        
        // Clear all chat-related state
        this.latestQuestion = '';
        this.agentResponse = '';
        this.currentMessage = '';
        this.errorMessage = '';
        this.liveTranscript = '';
        this.isTyping = false;
        
        // Clear any ongoing recording
        if (this.isRecording && this.recognition) {
            this.recognition.stop();
        }
        this.isRecording = false;
        
        console.log('handleCloseClick - Chat cleared and window closed');
    }

    handleClearChat(event) {
        // Clear all chat messages and reset state
        event.stopPropagation();
        event.preventDefault();
        
        console.log('handleClearChat - Clearing chat messages');
        
        // End agent session when clearing chat
        this.endAgentSession();
        
        // Clear all chat-related state
        this.latestQuestion = '';
        this.agentResponse = '';
        this.currentMessage = '';
        this.errorMessage = '';
        this.liveTranscript = '';
        
        // Stop recording if active
        if (this.isRecording && this.recognition) {
            this.recognition.stop();
        }
        this.isRecording = false;
        
        console.log('handleClearChat - Chat cleared successfully');
    }

    loadCurrentSuggestions() {
        const currentVideo = this.videos[this.currentSlideIndex];
        console.log('loadCurrentSuggestions - Current video:', currentVideo);
        console.log('loadCurrentSuggestions - Suggestion_Questions__c:', currentVideo?.Suggestion_Questions__c);
        
        if (currentVideo && currentVideo.Suggestion_Questions__c && currentVideo.Suggestion_Questions__c.trim() !== '') {
            // Split the comma-separated suggestions and clean them up
            this.currentSuggestions = currentVideo.Suggestion_Questions__c
                .split(',')
                .map(suggestion => suggestion.trim())
                .filter(suggestion => suggestion.length > 0);
            this.clickedSuggestions = []; // Reset clicked suggestions for new video
            console.log('loadCurrentSuggestions - Loaded suggestions:', this.currentSuggestions);
        } else {
            // No suggestions if field is blank or empty
            this.currentSuggestions = [];
            this.clickedSuggestions = [];
            console.log('loadCurrentSuggestions - No suggestions available');
        }
    }

    handleMessageChange(event) {
        this.currentMessage = event.target.value;
    }

    handleSendMessage() {
        if (this.currentMessage && this.currentMessage.trim()) {
            const question = this.currentMessage.trim();
            this.latestQuestion = question;
            this.currentMessage = '';
            this.processQuestion(question);
        }
    }

    handleKeyPress(event) {
        console.log('Key pressed:', event.key, 'Current message:', this.currentMessage);
        if (event.key === 'Enter') {
            event.preventDefault(); // Prevent form submission
            event.stopPropagation(); // Stop event bubbling
            console.log('Enter key detected, sending message:', this.currentMessage);
            this.handleSendMessage();
        }
    }

    async processQuestion(question) {
        try {
            // Show typing indicator
            const startTime = Date.now();
            this.isTyping = true;
            this.agentResponse = ''; // Clear previous response
            
            // Initialize agent session if not already done
            if (!this.agentSessionId) {
                await this.initializeAgentSession();
            }
            
            // Get agent recommendation from AgentforceController
            const response = await getAgentRecommendation({
                sessionId: this.agentSessionId,
                message: question,
                consumerKey: this.consumerKey,
                consumerSecret: this.consumerSecret
            });

            console.log('@@response::',response);
            
            // Show response after a delay (simulating AI processing)
            setTimeout(async () => {
                this.isTyping = false;
                this.agentResponse = response;
                
                // Calculate response time
                const responseTime = Date.now() - startTime;
                
                // Log the conversation to Salesforce
                await this.logInteraction(question, response, this.currentInteractionType || 'Text', responseTime);
                
                // Reset interaction type
                this.currentInteractionType = null;
            }, 1500);
        } catch (error) {
            console.error('Error processing question:', error);
            this.isTyping = false;
            this.errorMessage = 'Sorry, there was an error processing your question. Please try again.';
        }
    }

    handleSuggestedQuestion(event) {
        const question = event.target.dataset.question;
        this.latestQuestion = question;
        this.processQuestion(question);
        // Add clicked suggestion to the clicked list
        this.clickedSuggestions.push(question);
    }

    get availableSuggestions() {
        return this.currentSuggestions.filter(suggestion => 
            !this.clickedSuggestions.includes(suggestion)
        );
    }
    
    get voiceButtonClass() {
        return this.isRecording ? 'voice-button recording' : 'voice-button';
    }

    get hasChatMessages() {
        // Return true if there are any chat messages (question or response)
        return !!(this.latestQuestion || this.agentResponse);
    }

    scrollToBottom() {
        // Use setTimeout to ensure DOM is updated
        setTimeout(() => {
            const chatMessages = this.template.querySelector('.chat-messages');
            if (chatMessages) {
                chatMessages.scrollTop = chatMessages.scrollHeight;
            }
        }, 100);
    }

    async processVoiceQuery(question) {
        console.log('Processing voice query:', question);
        try {
            const currentVideo = this.videos[this.currentSlideIndex];
            console.log('Current video:', currentVideo);
            
            // Initialize agent session if not already done
            if (!this.agentSessionId) {
                await this.initializeAgentSession();
            }
            
            // Get agent recommendation from AgentforceController
            const response = await getAgentRecommendation({
                sessionId: this.agentSessionId,
                message: question,
                consumerKey: this.consumerKey,
                consumerSecret: this.consumerSecret
            });
            
            console.log('Agent Response:', response);
            this.agentResponse = response;
            this.showResponse = true;
            
            // Auto-hide response after 8 seconds
            setTimeout(() => {
                this.showResponse = false;
            }, 8000);
            
        } catch (error) {
            console.error('Error processing voice query:', error);
            this.agentResponse = 'Sorry, I encountered an error processing your question. Please try again.';
            this.showResponse = true;
        }
    }

    /**
     * Generate a unique session ID for conversation tracking
     * @return {string} Unique session ID
     */
    generateSessionId() {
        const timestamp = Date.now();
        const random = Math.random().toString(36).substr(2, 9);
        return `session-${timestamp}-${random}`;
    }

    /**
     * Log conversation interaction to Salesforce
     * @param {string} question - User's question
     * @param {string} response - AI's response
     * @param {string} interactionType - 'Voice' or 'Text'
     * @param {number} responseTime - Response time in milliseconds
     */
    async logInteraction(question, response, interactionType, responseTime) {
        try {
            // Verify sessionId exists
            if (!this.sessionId) {
                console.error('❌ SessionId is null or undefined! Cannot log conversation.');
                console.error('❌ Instance ID:', this.instanceId);
                console.error('❌ Attempting to regenerate session ID...');
                this.sessionId = this.generateSessionId();
                console.log('🔄 New Session ID generated:', this.sessionId);
            }
            
            const currentVideo = this.videos[this.currentSlideIndex];
            
            const conversationData = {
                sessionId: this.sessionId,
                question: question,
                response: response,
                interactionType: interactionType,
                videoId: currentVideo?.Id || null,
                responseTime: responseTime
            };
            
            console.log('📊 Logging conversation to Salesforce:');
            console.log('   - Session ID:', conversationData.sessionId);
            console.log('   - Question:', conversationData.question);
            console.log('   - Response:', conversationData.response);
            console.log('   - Interaction Type:', conversationData.interactionType);
            console.log('   - Video ID:', conversationData.videoId);
            console.log('   - Response Time:', conversationData.responseTime);
            
            const recordId = await logConversation({ conversationData });
            console.log('✅ Conversation logged successfully. Record ID:', recordId);
            
        } catch (error) {
            console.error('❌ Error logging conversation to Salesforce:', error);
            console.error('❌ Error details:', error.body?.message || error.message);
            console.error('❌ Stack trace:', error.stack);
            // Don't show error to user - this is background logging
            // The conversation still works even if logging fails
        }
    }

}