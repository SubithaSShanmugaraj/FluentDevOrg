/**
 * @description Service class for calculating lead scores based on Fluent Conversation data
 * Analyzes user engagement patterns, question types, and interaction frequency
 * to generate actionable lead intelligence
 */
public with sharing class FluentLeadScoringService {
    
    // Scoring weights
    private static final Integer VOICE_INTERACTION_POINTS = 15;
    private static final Integer TEXT_INTERACTION_POINTS = 10;
    private static final Integer HIGH_INTENT_KEYWORD_POINTS = 20;
    private static final Integer MEDIUM_INTENT_KEYWORD_POINTS = 10;
    private static final Integer MULTIPLE_SESSION_POINTS = 15;
    private static final Integer SAME_PRODUCT_FOCUS_POINTS = 20;
    private static final Integer RECENT_ACTIVITY_POINTS = 10;
    
    // High intent keywords (buying signals)
    private static final Set<String> HIGH_INTENT_KEYWORDS = new Set<String>{
        'price', 'cost', 'buy', 'purchase', 'order', 'payment',
        'shipping', 'delivery', 'available', 'stock', 'discount',
        'warranty', 'guarantee', 'return policy', 'when can i get'
    };
    
    // Medium intent keywords (research phase)
    private static final Set<String> MEDIUM_INTENT_KEYWORDS = new Set<String>{
        'features', 'specifications', 'compare', 'difference',
        'reviews', 'ratings', 'quality', 'best', 'recommend',
        'compatible', 'work with', 'support', 'how does'
    };
    
    /**
     * Calculate lead score for a user based on their conversation history
     * @param userId The user ID to calculate score for
     * @return LeadScoringResult wrapper with score and insights
     */
    public static LeadScoringResult calculateUserLeadScore(Id userId) {
        LeadScoringResult result = new LeadScoringResult();
        result.userId = userId;
        result.calculatedDate = DateTime.now();
        
        // Get all conversations for this user
        List<Fluent_Conversation__c> conversations = [
            SELECT Id, User_Question__c, Interaction_Type__c, 
                   Video__c, Session_ID__c, Interaction_Timestamp__c,
                   CreatedDate
            FROM Fluent_Conversation__c
            WHERE User__c = :userId
            ORDER BY CreatedDate DESC
        ];
        
        if (conversations.isEmpty()) {
            result.score = 0;
            result.intentLevel = 'None';
            return result;
        }
        
        Integer totalScore = 0;
        Set<String> uniqueSessions = new Set<String>();
        Set<Id> uniqueVideos = new Set<Id>();
        Integer highIntentQuestions = 0;
        Integer mediumIntentQuestions = 0;
        Integer voiceInteractions = 0;
        List<String> detectedKeywords = new List<String>();
        
        // Most recent conversation date
        DateTime lastInteractionDate = conversations[0].Interaction_Timestamp__c;
        
        // Analyze each conversation
        for (Fluent_Conversation__c conv : conversations) {
            // Track unique sessions
            if (String.isNotBlank(conv.Session_ID__c)) {
                uniqueSessions.add(conv.Session_ID__c);
            }
            
            // Track unique videos (product interest)
            if (conv.Video__c != null) {
                uniqueVideos.add(conv.Video__c);
            }
            
            // Score interaction type
            if (conv.Interaction_Type__c == 'Voice') {
                totalScore += VOICE_INTERACTION_POINTS;
                voiceInteractions++;
            } else if (conv.Interaction_Type__c == 'Text') {
                totalScore += TEXT_INTERACTION_POINTS;
            }
            
            // Analyze question content
            if (String.isNotBlank(conv.User_Question__c)) {
                String question = conv.User_Question__c.toLowerCase();
                
                // Check for high intent keywords
                for (String keyword : HIGH_INTENT_KEYWORDS) {
                    if (question.contains(keyword)) {
                        totalScore += HIGH_INTENT_KEYWORD_POINTS;
                        highIntentQuestions++;
                        detectedKeywords.add(keyword);
                        break; // Only count once per question
                    }
                }
                
                // Check for medium intent keywords
                for (String keyword : MEDIUM_INTENT_KEYWORDS) {
                    if (question.contains(keyword)) {
                        totalScore += MEDIUM_INTENT_KEYWORD_POINTS;
                        mediumIntentQuestions++;
                        if (!detectedKeywords.contains(keyword)) {
                            detectedKeywords.add(keyword);
                        }
                        break; // Only count once per question
                    }
                }
            }
        }
        
        // Bonus for multiple sessions (shows sustained interest)
        if (uniqueSessions.size() >= 3) {
            totalScore += MULTIPLE_SESSION_POINTS * 2;
        } else if (uniqueSessions.size() >= 2) {
            totalScore += MULTIPLE_SESSION_POINTS;
        }
        
        // Bonus for focused product interest
        if (uniqueVideos.size() == 1 && conversations.size() >= 3) {
            // Multiple questions about same product = high intent
            totalScore += SAME_PRODUCT_FOCUS_POINTS;
        }
        
        // Bonus for recent activity (within last 7 days)
        if (lastInteractionDate != null && 
            lastInteractionDate.addDays(7) >= DateTime.now()) {
            totalScore += RECENT_ACTIVITY_POINTS;
        }
        
        // Cap score at 100
        result.score = Math.min(totalScore, 100);
        
        // Determine intent level
        result.intentLevel = determineIntentLevel(result.score);
        
        // Set additional insights
        result.totalInteractions = conversations.size();
        result.uniqueSessions = uniqueSessions.size();
        result.uniqueProducts = uniqueVideos.size();
        result.highIntentQuestions = highIntentQuestions;
        result.mediumIntentQuestions = mediumIntentQuestions;
        result.voiceInteractions = voiceInteractions;
        result.lastInteractionDate = lastInteractionDate;
        result.detectedKeywords = String.join(detectedKeywords, ', ');
        result.mostRecentQuestion = conversations[0].User_Question__c;
        
        // Determine if user qualifies for lead creation
        result.qualifiesForLead = shouldCreateLead(result);
        
        return result;
    }
    
    /**
     * Determine intent level based on score
     */
    private static String determineIntentLevel(Integer score) {
        if (score >= 80) return 'Hot';
        if (score >= 60) return 'Warm';
        if (score >= 40) return 'Cold';
        return 'Low';
    }
    
    /**
     * Determine if user qualifies for lead creation
     */
    private static Boolean shouldCreateLead(LeadScoringResult result) {
        // Create lead if:
        // 1. Score >= 60 (Warm or Hot)
        // 2. OR has high intent questions
        // 3. OR multiple sessions with same product focus
        
        return result.score >= 60 || 
               result.highIntentQuestions >= 2 ||
               (result.uniqueSessions >= 2 && result.uniqueProducts == 1);
    }
    
    /**
     * Batch update lead scores for all users with conversations
     */
    public static void updateAllLeadScores() {
        // Get all unique users with conversations
        List<AggregateResult> userAggregates = [
            SELECT User__c
            FROM Fluent_Conversation__c
            WHERE User__c != NULL
            GROUP BY User__c
        ];
        
        List<Fluent_Conversation__c> conversationsToUpdate = new List<Fluent_Conversation__c>();
        
        for (AggregateResult ar : userAggregates) {
            Id userId = (Id)ar.get('User__c');
            LeadScoringResult result = calculateUserLeadScore(userId);
            
            // Update all conversations for this user with the calculated score
            List<Fluent_Conversation__c> userConversations = [
                SELECT Id
                FROM Fluent_Conversation__c
                WHERE User__c = :userId
            ];
            
            for (Fluent_Conversation__c conv : userConversations) {
                conv.Lead_Score__c = result.score;
                conv.Intent_Level__c = result.intentLevel;
                conversationsToUpdate.add(conv);
            }
        }
        
        if (!conversationsToUpdate.isEmpty()) {
            update conversationsToUpdate;
        }
    }
    
    /**
     * Wrapper class for lead scoring results
     */
    public class LeadScoringResult {
        public Id userId { get; set; }
        public Integer score { get; set; }
        public String intentLevel { get; set; }
        public Integer totalInteractions { get; set; }
        public Integer uniqueSessions { get; set; }
        public Integer uniqueProducts { get; set; }
        public Integer highIntentQuestions { get; set; }
        public Integer mediumIntentQuestions { get; set; }
        public Integer voiceInteractions { get; set; }
        public DateTime lastInteractionDate { get; set; }
        public DateTime calculatedDate { get; set; }
        public String detectedKeywords { get; set; }
        public String mostRecentQuestion { get; set; }
        public Boolean qualifiesForLead { get; set; }
        
        public LeadScoringResult() {
            this.score = 0;
            this.totalInteractions = 0;
            this.uniqueSessions = 0;
            this.uniqueProducts = 0;
            this.highIntentQuestions = 0;
            this.mediumIntentQuestions = 0;
            this.voiceInteractions = 0;
            this.qualifiesForLead = false;
        }
    }
}