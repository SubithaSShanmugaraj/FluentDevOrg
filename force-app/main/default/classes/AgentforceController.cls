/**
 * @description Controller for Einstein Agentforce AI integration
 * Manages OAuth authentication, session management, and message exchange with Einstein AI Agent API
 */
public with sharing class AgentforceController {
    private static final String API_ENDPOINT = 'https://api.salesforce.com/einstein/ai-agent/v1';
    
    // Cache the access token to avoid multiple authentication requests
    private static String cachedAccessToken;
    private static Long tokenExpiration = 0;

    /**
     * @description Get the OAuth authentication endpoint for the current org
     * @return String The OAuth token endpoint URL
     */
    private static String AUTH_ENDPOINT {
        get {
            // Use org's domain directly instead of login/test salesforce endpoints
            return URL.getOrgDomainUrl().toExternalForm() + '/services/oauth2/token';
        }
    }

    /**
     * @description Get the current organization's domain URL
     * @return String The organization domain URL
     */
    @AuraEnabled(cacheable=true)
    public static String getOrgDomain() {
        return URL.getOrgDomainUrl().toExternalForm();
    }

    /**
     * @description Get OAuth access token using client credentials flow with token caching
     * @param consumerKey The Connected App consumer key
     * @param consumerSecret The Connected App consumer secret
     * @return String The OAuth access token
     * @throws AuraHandledException if authentication fails
     */
    private static String getAccessToken(String consumerKey, String consumerSecret) {
            if (String.isBlank(consumerKey) || String.isBlank(consumerSecret)) {
                throw new AuraHandledException('Consumer Key and Consumer Secret are required for authentication');
            }
            
            // Check if we have a valid cached token
            Long currentTime = System.currentTimeMillis() / 1000;
            if (String.isNotBlank(cachedAccessToken) && tokenExpiration > currentTime + 60) {
                // Return cached token if it's not going to expire in the next minute
                System.debug('Using cached access token');
                return cachedAccessToken;
            }
            
            try {
                System.debug('Requesting new access token');
                // Build the authentication request using client credentials flow
                HttpRequest req = new HttpRequest();
                req.setEndpoint(AUTH_ENDPOINT);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                
                // Set timeout to 30 seconds
                req.setTimeout(30000);
                
                // Prepare request body for client credentials flow - using string concatenation instead of URL encoding
                String requestBody = 'grant_type=client_credentials' +
                    '&client_id=' + consumerKey +
                    '&client_secret=' + consumerSecret;
                
                System.debug('Auth request body: ' + requestBody.replace(consumerSecret, '[REDACTED]'));
                req.setBody(requestBody);
                
                // Log attempt to get token
                System.debug('Sending auth request to: ' + AUTH_ENDPOINT);
                
                HttpResponse res = new Http().send(req);
                System.debug('Auth response status: ' + res.getStatusCode());
                System.debug('Auth response body: ' + res.getBody());
                
                if (res.getStatusCode() == 200) {
                    Map<String, Object> tokenResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    cachedAccessToken = (String)tokenResponse.get('access_token');
                    
                    if (String.isBlank(cachedAccessToken)) {
                        System.debug('Error: No access_token in response. Response body: ' + res.getBody());
                        throw new AuraHandledException('No access_token returned in authentication response. Response: ' + res.getBody());
                    }
                    
                    // Calculate token expiration (default to 30 minutes if not provided)
                    Integer expiresIn = tokenResponse.containsKey('expires_in') 
                        ? Integer.valueOf(tokenResponse.get('expires_in')) 
                        : 1800; // 30 minutes in seconds
                    
                    tokenExpiration = currentTime + expiresIn;
                    System.debug('Token expires in: ' + expiresIn + ' seconds');
                    
                    return cachedAccessToken;
                }
                
                System.debug('Auth error: ' + res.getStatusCode() + ' ' + res.getStatus());
                System.debug('Auth error body: ' + res.getBody());
                
                // Handle specific OAuth error codes
                if (res.getStatusCode() == 400) {
                    throw new AuraHandledException('Invalid OAuth request. Please check your consumer key and secret.');
                } else if (res.getStatusCode() == 401) {
                    throw new AuraHandledException('OAuth authentication failed. Invalid consumer key or secret.');
                } else if (res.getStatusCode() == 403) {
                    throw new AuraHandledException('OAuth access forbidden. Please check your connected app permissions.');
                }
                
                throw new AuraHandledException('Authentication failed: ' + res.getStatusCode() + ' ' + res.getBody());
            } catch (Exception e) {
                System.debug('Exception getting access token: ' + e.getMessage() + ', Type: ' + e.getTypeName() + ', Line: ' + e.getLineNumber() + ', Stack: ' + e.getStackTraceString());
                throw new AuraHandledException('Error authenticating: ' + e.getMessage());
            }
        }    

    /**
     * @description Initialize a new Einstein Agent session with context variables
     * @param agentId The Einstein Agent ID
     * @param consumerKey The Connected App consumer key
     * @param consumerSecret The Connected App consumer secret
     * @param campaignId Optional campaign ID for context
     * @param productCode Optional product code for context
     * @return String The session ID for the created agent session
     * @throws AuraHandledException if session initialization fails
     */
    @AuraEnabled(cacheable=false)
    public static String initializeAgentSession(String agentId, String consumerKey, String consumerSecret, String campaignId, String productCode) {
        System.debug('Starting initializeAgentSession with agentId: ' + agentId);
        
        try {
            if (String.isBlank(agentId)) {
                throw new AuraHandledException('Agent ID cannot be blank');
            }
            
            if (String.isBlank(consumerKey) || String.isBlank(consumerSecret)) {
                throw new AuraHandledException('Consumer Key and Consumer Secret are required');
            }
            
            // Sanitize inputs to prevent special character issues
            consumerKey = consumerKey.trim();
            consumerSecret = consumerSecret.trim();

            // Get OAuth access token
            String accessToken = getAccessToken(consumerKey, consumerSecret);
            
            if (String.isBlank(accessToken)) {
                throw new AuraHandledException('Failed to obtain access token');
            }
            
            String endpoint = API_ENDPOINT + '/agents/' + agentId + '/sessions';
            System.debug('Calling API endpoint: ' + endpoint);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setTimeout(30000);
            
            System.debug('@@campaignId::' + campaignId);
            System.debug('@@productCode::' + productCode);

            // Add 30 second timeout

            Map<String, Object> payload = new Map<String, Object>{
                'externalSessionKey'    => generateUUID(),
                'instanceConfig'        => new Map<String, Object>{ 'endpoint' => URL.getOrgDomainUrl().toExternalForm() },
                'streamingCapabilities' => new Map<String, Object>{ 'chunkTypes' => new List<String>{ 'Text' } },
                'bypassUser'            => true,
                'variables'             => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'name'  => '$Context.campaignId',
                        'type'  => 'Text',
                        'value' => String.isBlank(campaignId) ? '' : campaignId
                    },
                    new Map<String, Object>{
                        'name'  => '$Context.productCode',
                        'type'  => 'Text',
                        'value' => String.isBlank(productCode) ? '' : productCode
                    }
                }
            };
            String requestBody = JSON.serialize(payload);
            System.debug('Request payload: ' + requestBody);
            req.setBody(requestBody);

            HttpResponse res = new Http().send(req);
            System.debug('Response status: ' + res.getStatusCode());
            System.debug('Response body: ' + res.getBody());
            
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String sessionId = (String)result.get('sessionId');
                if (String.isBlank(sessionId)) {
                    System.debug('No sessionId in response: ' + res.getBody());
                    throw new AuraHandledException('No sessionId returned in response');
                }
                System.debug('Session created successfully with ID: ' + sessionId);
                return sessionId;
            }
            
            // Create a detailed error message
            String errorDetails = 'Status: ' + res.getStatusCode() + 
                                  ', StatusText: ' + res.getStatus() + 
                                  ', Body: ' + res.getBody();
            System.debug('API call failed: ' + errorDetails);
            
            // Handle specific HTTP error codes
            if (res.getStatusCode() == 401) {
                throw new AuraHandledException('Authentication failed. Please check your credentials.');
            } else if (res.getStatusCode() == 403) {
                throw new AuraHandledException('Access forbidden. Please check your agent permissions.');
            } else if (res.getStatusCode() == 404) {
                throw new AuraHandledException('Agent not found. Please check your agent ID.');
            } else if (res.getStatusCode() >= 500) {
                throw new AuraHandledException('Server error. Please try again later.');
            }
            
            throw new AuraHandledException('Session init failed (' + res.getStatusCode() + '): ' + res.getBody());
        } catch (Exception e) {
            String errorMsg = 'Exception in initializeAgentSession: ' + e.getMessage() + 
                ', Type: ' + e.getTypeName() + 
                ', Line: ' + e.getLineNumber();
            System.debug(errorMsg);
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error initializing session: ' + e.getMessage());
        }
    }

    /**
     * @description Send a message to the Einstein Agent and get a response
     * @param sessionId The active agent session ID
     * @param message The user's message/question
     * @param consumerKey The Connected App consumer key
     * @param consumerSecret The Connected App consumer secret
     * @return String The AI agent's response message
     * @throws AuraHandledException if message exchange fails
     */
    @AuraEnabled(cacheable=false)
    public static String getAgentRecommendation(String sessionId, String message, String consumerKey, String consumerSecret) {
        if (String.isBlank(sessionId) || String.isBlank(message)) {
            throw new AuraHandledException('Session ID and message cannot be blank');
        }

        try {
            // Get OAuth access token
            String accessToken = getAccessToken(consumerKey, consumerSecret);
            
            Integer seq = incrementSequence(sessionId);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(API_ENDPOINT + '/sessions/' + sessionId + '/messages');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setTimeout(120000); // Setting timeout to 120 seconds (matches API documentation)

            Map<String, Object> messagePayload = new Map<String, Object>{
                'message'   => new Map<String, Object>{ 'sequenceId' => seq, 'type' => 'Text', 'text' => message },
                'variables' => new List<Object>()
            };
            
            String requestBody = JSON.serialize(messagePayload);
            System.debug('Request payload: ' + requestBody);
            req.setBody(requestBody);

            HttpResponse res = new Http().send(req);
            System.debug('Response status: ' + res.getStatusCode());
            System.debug('Response body: ' + res.getBody());
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                List<Object> msgs = (List<Object>)result.get('messages');
                return msgs.isEmpty() ? '' : (String)((Map<String, Object>)msgs.get(0)).get('message');
            }
            
            // Log any error responses
            System.debug('API error: Status=' + res.getStatusCode() + ', Body=' + res.getBody());
            throw new AuraHandledException('Agent response failed (' + res.getStatusCode() + '): ' + res.getBody());
        } catch (Exception e) {
            System.debug('Exception in getAgentRecommendation: ' + e.getMessage() + ', Type: ' + e.getTypeName() + ', Line: ' + e.getLineNumber() + ', Stack: ' + e.getStackTraceString());
            throw new AuraHandledException('Error getting agent response: ' + e.getMessage());
        }
    }

    /**
     * @description End an active Einstein Agent session
     * @param sessionId The active agent session ID to terminate
     * @param consumerKey The Connected App consumer key
     * @param consumerSecret The Connected App consumer secret
     * @return String Status message indicating session termination result
     * @throws AuraHandledException if session termination fails
     */
    @AuraEnabled(cacheable=false)
    public static String endAgentSession(String sessionId, String consumerKey, String consumerSecret) {
        if (String.isBlank(sessionId)) {
            throw new AuraHandledException('Session ID cannot be blank');
        }
        
        try {
            // Get OAuth access token
            String accessToken = getAccessToken(consumerKey, consumerSecret);
            
            // Use the API_ENDPOINT constant instead of hardcoding the URL
            HttpRequest req = new HttpRequest();
            req.setEndpoint(API_ENDPOINT + '/sessions/' + sessionId);
            req.setMethod('DELETE');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('x-session-end-reason', 'UserRequest');
            req.setHeader('Content-Type', 'application/json'); // Add content type header
            
            // Add an empty body with any required parameters to satisfy the arg2 requirement
            req.setBody('{}');
            
            System.debug('Ending session with endpoint: ' + req.getEndpoint());
            HttpResponse res = new Http().send(req);
            System.debug('End session response: Status=' + res.getStatusCode() + ', Body=' + res.getBody());
            
            // Clear sequence ID for this session when it ends
            if (seqIds.containsKey(sessionId)) {
                seqIds.remove(sessionId);
            }
            
            return (res.getStatusCode() == 204) ? 'Session ended' : 'End error (' + res.getStatusCode() + '): ' + res.getBody();
        } catch (Exception e) {
            System.debug('Exception in endAgentSession: ' + e.getMessage());
            throw new AuraHandledException('Error ending session: ' + e.getMessage());
        }
    }

    private static Map<String,Integer> seqIds = new Map<String,Integer>();
    
    /**
     * @description Increment and track message sequence ID for a session
     * @param sessionId The agent session ID
     * @return Integer The next sequence number for the session
     */
    private static Integer incrementSequence(String sessionId) {
        Integer seq = seqIds.containsKey(sessionId) ? seqIds.get(sessionId) + 1 : 1;
        seqIds.put(sessionId, seq);
        return seq;
    }

    /**
     * @description Generate a unique UUID for external session keys
     * @return String A random UUID string
     */
    private static String generateUUID() {
        return UUID.randomUUID().toString();
    }

}