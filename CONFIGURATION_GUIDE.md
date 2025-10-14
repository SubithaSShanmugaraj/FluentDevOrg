# Configuration Guide

## 🔐 Setting Up Salesforce OAuth Credentials

This guide will help you configure the necessary credentials for the Fluent Smart Shop application.

## Required Credentials

You'll need to configure the following in your Salesforce org:

### 1. **Salesforce Connected App (OAuth Credentials)**

#### Create Connected App:
1. Go to **Setup** → **Apps** → **App Manager**
2. Click **"New Connected App"**
3. Fill in the details:
   - **Connected App Name**: `Fluent Agentforce Integration`
   - **API Name**: `Fluent_Agentforce_Integration`
   - **Contact Email**: Your email
4. Enable OAuth Settings:
   - ✅ **Enable OAuth Settings**
   - **Callback URL**: `https://login.salesforce.com/services/oauth2/callback`
   - **Selected OAuth Scopes**:
     - `api` - Access the Salesforce API
     - `refresh_token, offline_access` - Perform requests at any time
5. Click **"Save"**
6. Click **"Continue"**
7. Copy the **Consumer Key** and **Consumer Secret**

### 2. **Einstein Agentforce Agent ID**

1. Go to **Setup** → **Einstein** → **Agentforce**
2. Find your agent (e.g., "Fluent")
3. Click on the agent
4. Copy the **Agent ID** (format: `0XxgK000000xxxxxx`)

## Configuration Options

You have **two ways** to configure credentials:

### **Option 1: Named Credentials (Recommended for Production)**

This is the most secure approach for production deployments.

#### Steps:
1. Go to **Setup** → **Security** → **Named Credentials**
2. Click **"New Named Credential"**
3. Configure:
   - **Label**: `Agentforce_OAuth`
   - **Name**: `Agentforce_OAuth`
   - **URL**: `https://login.salesforce.com/services/oauth2/token`
   - **Identity Type**: `Named Principal`
   - **Authentication Protocol**: `OAuth 2.0`
   - **Authentication Flow Type**: `Client Credentials`
   - **Client ID**: Paste your Consumer Key
   - **Client Secret**: Paste your Consumer Secret
4. Click **"Save"**

#### Update the Code:
Then modify `fluentAgentLWC.js` to use Named Credentials instead of hardcoded values.

### **Option 2: Custom Metadata Types (Recommended for Multiple Environments)**

1. Go to **Setup** → **Custom Metadata Types**
2. Click **"New Custom Metadata Type"**
3. Create `Agentforce_Config__mdt` with fields:
   - `Consumer_Key__c` (Text, 255)
   - `Consumer_Secret__c` (Text, 255)
   - `Agent_ID__c` (Text, 18)
4. Create a record for your environment
5. Update the component to read from Custom Metadata

### **Option 3: Hardcode in Component (Development/Testing Only)**

⚠️ **Warning**: Never commit real credentials to version control!

1. Open `force-app/main/default/lwc/fluentAgentLWC/fluentAgentLWC.js`
2. Replace placeholders:
   ```javascript
   @track consumerKey = 'YOUR_ACTUAL_CONSUMER_KEY';
   @track consumerSecret = 'YOUR_ACTUAL_CONSUMER_SECRET';
   @track agentId = 'YOUR_ACTUAL_AGENT_ID';
   ```
3. **DO NOT commit these changes to GitHub**

## Environment Variables Setup

For developers working locally, you can:

1. Create a `.env.local` file (this file is gitignored):
   ```env
   SF_CONSUMER_KEY=your_key_here
   SF_CONSUMER_SECRET=your_secret_here
   SF_AGENT_ID=your_agent_id_here
   ```

2. Never commit `.env.local` or any file with real credentials

## Security Best Practices

✅ **DO:**
- Use Named Credentials for production
- Use Custom Metadata for multi-environment setups
- Rotate credentials regularly
- Limit OAuth scope to minimum required
- Use IP restrictions in Connected App

❌ **DON'T:**
- Commit credentials to version control
- Share credentials in chat/email
- Use production credentials in development
- Hardcode credentials in production code

## Testing Your Configuration

After configuration, test the integration:

1. Open your Experience Cloud site
2. Click "Ask Fluent" on the conversational ad player
3. Ask a test question
4. Verify you receive a response from Agentforce

If you encounter errors, check:
- Consumer Key and Secret are correct
- Agent ID is valid
- OAuth scopes are sufficient
- Network connectivity to Salesforce

## Troubleshooting

### Error: "Invalid Client"
**Solution**: Verify your Consumer Key is correct

### Error: "Invalid Client Secret"
**Solution**: Regenerate the Consumer Secret in the Connected App

### Error: "Agent Not Found"
**Solution**: Verify the Agent ID and ensure the agent is active

### Error: "Insufficient Privileges"
**Solution**: Add the necessary OAuth scopes to your Connected App

## Additional Resources

- [Salesforce OAuth Documentation](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_flows.htm)
- [Named Credentials Setup](https://help.salesforce.com/s/articleView?id=sf.named_credentials_about.htm)
- [Einstein Agentforce Documentation](https://help.salesforce.com/s/articleView?id=sf.einstein_bots.htm)

---

**Need Help?** Open an issue on GitHub with details about your error (without including actual credentials).

