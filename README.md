# 🎥 Fluent – The Conversational Layer for Video Ads

> **"Don't just watch ads. Talk to them."**  
> Fluent transforms one-way video ads into two-way, intelligent conversations that inform, engage, and convert — all without leaving the ad.

---

## 🚀 Overview

**Fluent** reimagines digital advertising by embedding an AI-powered conversational agent directly into video ads.  
Instead of forcing users to click out, Fluent enables real-time, in-ad interaction — answering questions, personalizing offers, and guiding viewers from curiosity → conversion.

It's **not a chatbot**, it's a **conversation woven into storytelling**.

---

## 💡 Problem

Traditional video ads are passive and one-dimensional — they talk *at* people, not *with* them.  
Users lose interest or abandon potential purchases because they have **unanswered questions** like:

- "Does this come in my size?"
- "Can you ship to Paris?"
- "Is this eco-friendly?"

Each unanswered question = friction.  
**Friction kills conversions.**

---

## 🧠 Solution: Fluent

Fluent adds a **conversational layer** on top of existing video ads.

### 🗣 How It Works

1. 🎬 The ad plays as normal.
2. 💬 Smart prompts appear at key moments — "Want to see it in another color?"
3. 🤖 Fluent responds contextually to questions, explains features, or recommends products.
4. 🛒 Users can purchase or take action directly inside the ad — no redirects, no friction.

---

## ⚙️ Features

### **✨ Experience Cloud**
- Delivers personalized, interactive ad experiences within the video itself.  
- Connects with customer data to adapt offers and interactions in real time.

### **🤖 Agent – Fluent**
- AI-powered conversational agent that answers user queries naturally and contextually.  
- Maintains brand tone and provides instant product or service details.

### **🎯 Lead Predictive Scoring**
- Uses engagement patterns and conversation depth to identify high-intent leads.  
- Helps brands focus efforts on users most likely to convert.

### **📊 Analytics**
- Tracks engagement, sentiment, and conversion insights from every conversation.  
- Provides actionable data to optimize ad campaigns and creative strategies.

---

## 🌍 Impact

### For Advertisers
- 🚀 **2–3× more engagement** than static video ads.  
- ❌ **Reduced drop-offs** by answering questions in-ad.  
- 💰 **Drive conversions directly** without redirects.  
- 🔄 **Enable new pricing models** like "cost per conversation."

### For Consumers
- 💬 **Instant answers**, no site-hopping.  
- 🤝 **Human-like, transparent interaction** within the ad.  
- ⚡ **Frictionless journey** from interest to purchase.

---

## 🧱 Architecture Overview

```
[ User Interaction Layer ]
├── Tap/Voice Detection
├── Adaptive Prompt Overlay

[ Fluent AI Core ]
├── NLP (Agentforce) + Intent Recognition
├── Product & Recommendation Engine
├── Brand-Tuned Response Generator

[ Data & Analytics Layer ]
├── Engagement Tracking
├── Lead Scoring
├── Campaign Insights

[ Integrations ]
├── Experience Cloud
```

---

## 🛠 Tech Stack

- **Frontend:** Experience Cloud 
- **Backend:** LWC, Apex Class, Apex Trigger, Flow
- **AI & ML:** Agentforce Agents
- **Data & Analytics:** Reports & Dashboards 

---

## 📦 Installation

### Prerequisites
- Salesforce Org (Developer Edition or higher)
- Salesforce CLI installed
- Einstein Agentforce enabled
- Experience Cloud license

### Deployment Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/SubithaSShanmugaraj/FluentDevOrg.git
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

4. **Configure Agentforce credentials**
   - Follow the `CONFIGURATION_GUIDE.md` for setting up OAuth credentials
   - Enable the Fluent bot in Einstein Agentforce settings

5. **Set up Experience Cloud site**
   - Create a new Experience Cloud site
   - Add the `conversationalAdPlayer` component
   - Configure member access and sharing rules

---

## 🎯 Key Components

### Custom Objects
- `Ad_Campaign__c` - Campaign grouping for videos
- `Ad_Video__c` - Video metadata and content
- `Fluent_Conversation__c` - Conversation logging and analytics
- `E_Cart_Product__c` - Product catalog integration

### Lightning Web Components
- `conversationalAdPlayer` - Main floating video carousel with AI chat
- Supports voice and text input
- Real-time AI responses via Einstein Agentforce

### Apex Controllers
- `AdCampaignController` - Fetch campaign videos
- `AgentforceController` - AI API integration
- `FluentConversationController` - Conversation logging
- `ProductController` - Product data access

---

## 🔒 Ethical Design

Fluent is built with **privacy and transparency** at its core:

- User engagement is **opt-in**, never forced.  
- No invasive tracking or dark patterns.  
- "Privacy by Design" principles — compliant with GDPR/CCPA.  
- Always polite, brand-safe, and respectful tone.

---

## 📈 Analytics & Insights

### Pre-built Reports
- **Conversation Volume by Hour** - Track engagement patterns
- **Lead Conversation Intelligence** - Analyze lead quality
- **Hot Leads Report** - High-intent lead identification
- **Lead Age and Follow-up Analysis** - Lead nurturing insights

### Lead Scoring
- Automated lead scoring based on:
  - Conversation depth and engagement
  - Product interest signals
  - Question intent analysis
- Automatic lead creation for high-scoring interactions

---

## 🔮 Future Scope

- 🗣 Voice-enabled interactive ads  
- 🎮 Gamified ad experiences  
- 🧭 Cross-platform (OTT, AR/VR ads)  
- 📊 Predictive engagement analytics  
- 💳 Integrated checkout APIs  

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🏁 Mission

Fluent redefines video advertising — from **passive impressions** to **active conversations**.  
Because when ads listen, people respond. 💬

---
