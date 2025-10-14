# Fluent Smart Shop - Conversational Ad Player

## 🎯 Project Overview

Fluent Smart Shop is an innovative Salesforce Experience Cloud application featuring a conversational AI-powered ad player. The system combines video advertising with Einstein Agentforce to create an interactive shopping experience where customers can ask questions about products directly while watching promotional videos.

## 🌟 Key Features

### 1. **Conversational Ad Player (LWC)**
- Floating video carousel with drag-and-drop functionality
- Video enlargement with dimmed background for focused viewing
- Voice and text input for customer queries
- Real-time AI responses powered by Einstein Agentforce
- Gradient-styled UI with smooth animations
- Mobile-responsive design

### 2. **Einstein Agentforce Integration**
- Natural language processing for customer questions
- Context-aware responses based on video content
- Product recommendations and information
- Session-based conversation tracking

### 3. **Lead Intelligence & Scoring**
- Automatic conversation logging to Salesforce
- Lead scoring based on engagement metrics
- Automated lead creation from high-intent interactions
- Comprehensive conversation analytics

### 4. **Experience Cloud Integration**
- External user (customer portal) support
- Secure data access with sharing rules
- Seamless authentication and authorization

## 📊 Architecture

### Component Stack
- **Frontend**: Lightning Web Components (LWC)
- **Backend**: Apex Controllers with security best practices
- **AI Integration**: Einstein Agentforce API
- **Database**: Salesforce Custom Objects
- **Platform**: Salesforce Experience Cloud

### Custom Objects
- `Ad_Campaign__c` - Campaign grouping for videos
- `Ad_Video__c` - Video metadata and content
- `Fluent_Conversation__c` - Conversation logging and analytics
- `E_Cart_Product__c` - Product catalog integration

## 🚀 Installation

### Prerequisites
- Salesforce Org (Developer Edition or higher)
- Salesforce CLI installed
- Einstein Agentforce enabled
- Experience Cloud license

### Deployment Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/FluentDevOrg.git
   cd FluentDevOrg
   ```

2. **Authenticate to your Salesforce org**
   ```bash
   sf org login web --set-default-dev-hub --alias DevHub
   ```

3. **Deploy the metadata**
   ```bash
   sf project deploy start --source-dir force-app
   ```

4. **Assign permission set (optional)**
   ```bash
   sf org assign permset --name Fluent_Smart_Shop_Video_Access
   ```

5. **Load sample data (optional)**
   ```bash
   sf apex run --file scripts/setup_chromecast_data.apex
   ```

## 📝 Configuration

### 1. **Einstein Agentforce Setup**
- Navigate to Setup → Einstein → Agentforce
- Enable the Fluent bot (`Fluent.bot-meta.xml`)
- Configure OAuth credentials in Named Credentials
- Update `AgentforceController` with your API endpoints

### 2. **Experience Cloud Site Setup**
- Create a new Experience Cloud site
- Add "Fluent Smart Shop Users" profile
- Configure sharing settings for external users
- Add the `conversationalAdPlayer` component to your site pages

### 3. **Campaign Configuration**
- Create a new `Ad_Campaign__c` record
- Add `Ad_Video__c` records with video URLs
- Link videos to products via `Product_Code__c`
- Add the Campaign ID to the LWC component in Experience Builder

## 🔧 Component Reference

### Main LWC Component
**Path**: `force-app/main/default/lwc/conversationalAdPlayer/`

**Key Properties**:
- `recordId` - Campaign ID (required)

**Usage in Experience Builder**:
1. Drag the component onto your page
2. Set the Campaign ID property
3. Publish and test

### Apex Controllers

| Class | Purpose | Security |
|-------|---------|----------|
| `AdCampaignController` | Fetch campaign videos | WITH/WITHOUT SHARING |
| `AgentforceController` | AI API integration | WITH SHARING |
| `AgentforceService` | Legacy AI service | WITH SHARING |
| `FluentConversationController` | Conversation logging | WITH SHARING |
| `ProductController` | Product data access | WITH SHARING |

## 📈 Analytics & Reports

### Pre-built Reports
1. **Conversation Volume by Hour** - Track engagement patterns
2. **Lead Conversation Intelligence** - Analyze lead quality
3. **Hot Leads Report** - High-intent lead identification
4. **Lead Age and Follow-up Analysis** - Lead nurturing insights

### Custom Report Types
- `Fluent_Conversations` - Base conversation analytics
- `Fluent_Lead_Intelligence` - Lead-focused reporting

### Dashboard
Follow `LEAD_GENERATION_DASHBOARD_GUIDE.md` for setting up the comprehensive Lead Intelligence Dashboard.

## 🔐 Security Features

### Data Security
- Field-Level Security (FLS) checks in all Apex classes
- `WITH USER_MODE` in SOQL queries
- `WITH SHARING` / `WITHOUT SHARING` appropriately applied
- CRUD permission validation

### External User Access
- External Sharing Model: `Read` for `Ad_Video__c` and `E_Cart_Product__c`
- Custom profile: "Fluent Smart Shop User"
- Permission set for additional access control

## 🧪 Testing

### Run All Tests
```bash
sf apex run test --test-level RunLocalTests --result-format human
```

### Test Classes
- `AdCampaignControllerTest` - 100% coverage
- `AgentforceControllerTest` - Mock HTTP callouts
- `AgentforceServiceTest` - Alternative service testing
- `FluentConversationControllerTest` - Conversation logging
- `ProductControllerTest` - Product queries
- `FluentLeadScoringServiceTest` - Lead scoring logic
- `FluentLeadCreationServiceTest` - Lead automation

## 📚 Documentation

- `FLUENT_DESIGN_DOCUMENT.md` - Complete system architecture
- `LEAD_GENERATION_REPORTS_GUIDE.md` - Report creation guide
- `LEAD_GENERATION_DASHBOARD_GUIDE.md` - Dashboard setup guide
- `PRODUCT_IMAGE_SETUP_GUIDE.md` - Image hosting solutions
- `AD_VIDEO_VISIBILITY_FIX_SUMMARY.md` - Troubleshooting external user access

## 🎥 Demo Video URLs

Sample Chromecast promotional videos are included:
- ForBiggerEscapes.mp4
- ForBiggerJoyrides.mp4
- ForBiggerFun.mp4

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Salesforce Trailhead for comprehensive learning resources
- Einstein Agentforce team for AI capabilities
- Open-source LWC community for inspiration

## 📞 Support

For issues, questions, or contributions, please open an issue on GitHub.

## 🔄 Version History

- **v1.0.0** - Initial release with core conversational ad player
- Features: Voice/text input, AI responses, lead scoring, analytics

---

**Built with ❤️ using Salesforce Lightning Web Components and Einstein Agentforce**
