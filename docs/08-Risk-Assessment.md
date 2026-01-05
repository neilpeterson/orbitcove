# OrbitCove - Risk Assessment

**Version**: 1.0 Draft
**Last Updated**: January 2026
**Status**: Review

---

## Table of Contents

1. [Risk Framework](#risk-framework)
2. [Technical Risks](#technical-risks)
3. [Product Risks](#product-risks)
4. [Market Risks](#market-risks)
5. [Security & Privacy Risks](#security--privacy-risks)
6. [Operational Risks](#operational-risks)
7. [Financial Risks](#financial-risks)
8. [Legal & Compliance Risks](#legal--compliance-risks)
9. [Risk Register Summary](#risk-register-summary)
10. [Monitoring & Review](#monitoring--review)

---

## Risk Framework

### Risk Scoring

Each risk is evaluated on two dimensions:

**Likelihood** (L):
| Score | Label | Description |
|-------|-------|-------------|
| 1 | Rare | < 10% chance |
| 2 | Unlikely | 10-25% chance |
| 3 | Possible | 25-50% chance |
| 4 | Likely | 50-75% chance |
| 5 | Almost Certain | > 75% chance |

**Impact** (I):
| Score | Label | Description |
|-------|-------|-------------|
| 1 | Negligible | Minor inconvenience, easily resolved |
| 2 | Minor | Some rework, delays < 1 week |
| 3 | Moderate | Significant rework, delays 1-4 weeks |
| 4 | Major | Major rework, delays 1-3 months, partial feature cut |
| 5 | Severe | Project failure, pivot required, launch blocked |

**Risk Score** = Likelihood × Impact

| Score Range | Priority | Action |
|-------------|----------|--------|
| 1-4 | Low | Monitor |
| 5-9 | Medium | Mitigation plan required |
| 10-15 | High | Active mitigation, contingency ready |
| 16-25 | Critical | Immediate action, escalate |

---

## Technical Risks

### T1: Offline Sync Complexity

| Attribute | Value |
|-----------|-------|
| **Description** | Offline-first architecture with sync queue is complex. Edge cases around conflict resolution, partial syncs, and network recovery could cause data inconsistency or loss. |
| **Likelihood** | 4 (Likely) |
| **Impact** | 4 (Major) |
| **Risk Score** | 16 (Critical) |
| **Category** | Technical |

**Consequences**:
- Users lose data they created offline
- Duplicate content appears after sync
- Conflicting edits overwrite each other unexpectedly
- Users lose trust in the app

**Mitigation Strategies**:
1. **Simple conflict resolution**: Last-write-wins for MVP; no complex merge logic
2. **Extensive testing**: Automated tests for all sync scenarios
3. **Sync status UI**: Clear indicators showing pending/synced/failed
4. **Manual retry**: Users can force retry failed operations
5. **Audit logging**: Track all sync operations for debugging

**Contingency**:
- If sync issues persist, fall back to online-only for writes (read cache only)
- Add user-facing "sync history" to manually resolve conflicts

**Owner**: iOS Lead
**Status**: Open

---

### T2: Azure AD B2C Complexity

| Attribute | Value |
|-----------|-------|
| **Description** | Azure AD B2C configuration is complex. Sign in with Apple integration requires specific setup. Misconfigurations could block all authentication. |
| **Likelihood** | 3 (Possible) |
| **Impact** | 5 (Severe) |
| **Risk Score** | 15 (High) |
| **Category** | Technical |

**Consequences**:
- Users cannot sign in
- Launch blocked until resolved
- Debugging B2C issues is time-consuming

**Mitigation Strategies**:
1. **Early prototyping**: Set up B2C + SIWA in Phase 0, before other work
2. **Documentation**: Follow Azure tutorials exactly
3. **Fallback plan**: Prepare simple JWT auth as backup (no B2C)
4. **Test accounts**: Create test users for different scenarios
5. **Azure support**: Budget for support ticket if stuck

**Contingency**:
- If B2C proves too complex, implement simple JWT auth with Apple ID token validation directly (bypass B2C)

**Owner**: Backend Lead
**Status**: Open

---

### T3: Push Notification Reliability

| Attribute | Value |
|-----------|-------|
| **Description** | Push notifications via APNs are not guaranteed. Notifications may be delayed, dropped, or not delivered at all, especially on low-power mode or poor network. |
| **Likelihood** | 4 (Likely) |
| **Impact** | 3 (Moderate) |
| **Risk Score** | 12 (High) |
| **Category** | Technical |

**Consequences**:
- Users miss important events/announcements
- RSVPs not submitted in time
- Perception that app "doesn't work"

**Mitigation Strategies**:
1. **In-app notification center**: Don't rely solely on push
2. **Badge counts**: Update badge even if notification not shown
3. **Email fallback**: Optional email digest for critical notifications
4. **Background refresh**: Pull notifications when app opens
5. **Retry logic**: Server retries failed pushes

**Contingency**:
- Add SMS notifications for critical alerts (cost implications)
- Implement email-based notifications as primary channel

**Owner**: Backend Lead
**Status**: Open

---

### T4: Vapor Ecosystem Limitations

| Attribute | Value |
|-----------|-------|
| **Description** | Vapor (Swift server) has a smaller ecosystem than Node.js or .NET. Some libraries may be missing, outdated, or poorly documented. |
| **Likelihood** | 3 (Possible) |
| **Impact** | 3 (Moderate) |
| **Risk Score** | 9 (Medium) |
| **Category** | Technical |

**Consequences**:
- Time spent writing custom implementations
- Fewer Stack Overflow answers for issues
- Potential performance issues with immature libraries

**Mitigation Strategies**:
1. **Dependency audit**: List all required libraries upfront, verify they exist
2. **Prototype early**: Test critical integrations (Stripe, Azure) before committing
3. **Fallback identified**: .NET 8 as backup (more mature Azure integration)
4. **Community engagement**: Join Vapor Discord for support

**Contingency**:
- Rewrite backend in .NET 8 if Vapor proves unworkable (significant delay)
- Use external microservices for problematic integrations

**Owner**: Backend Lead
**Status**: Open

---

### T5: SwiftData Maturity

| Attribute | Value |
|-----------|-------|
| **Description** | SwiftData is relatively new (iOS 17). There may be bugs, performance issues, or missing features compared to Core Data. |
| **Likelihood** | 3 (Possible) |
| **Impact** | 3 (Moderate) |
| **Risk Score** | 9 (Medium) |
| **Category** | Technical |

**Consequences**:
- Data corruption issues
- Migration problems between versions
- Performance issues with large datasets

**Mitigation Strategies**:
1. **Simple schema**: Avoid complex relationships where possible
2. **Testing**: Extensive unit tests for data operations
3. **Monitoring**: Track database performance in production
4. **Backup strategy**: Regular exports of user data
5. **Migration plan**: Document schema changes carefully

**Contingency**:
- Fall back to Core Data if SwiftData has critical issues
- Use SQLite directly with GRDB library

**Owner**: iOS Lead
**Status**: Open

---

### T6: Image/Media Performance

| Attribute | Value |
|-----------|-------|
| **Description** | Photo uploads, downloads, and display could cause performance issues. Large images consume bandwidth, storage, and memory. |
| **Likelihood** | 3 (Possible) |
| **Impact** | 2 (Minor) |
| **Risk Score** | 6 (Medium) |
| **Category** | Technical |

**Consequences**:
- Slow uploads frustrate users
- High data usage complaints
- Memory pressure causes crashes
- Storage costs exceed budget

**Mitigation Strategies**:
1. **Image compression**: Resize and compress before upload
2. **Thumbnails**: Generate and cache thumbnails
3. **Lazy loading**: Load images only when visible
4. **CDN caching**: Azure Front Door for fast delivery
5. **Storage limits**: Cap storage per community

**Contingency**:
- Reduce image quality further
- Implement paid storage tiers earlier than planned

**Owner**: iOS Lead
**Status**: Open

---

## Product Risks

### P1: Too Complex for Target Users

| Attribute | Value |
|-----------|-------|
| **Description** | Target users include "grandma" and busy parents. If the app is too complex, they won't adopt it. Competitors failed here (BAND is cluttered). |
| **Likelihood** | 3 (Possible) |
| **Impact** | 5 (Severe) |
| **Risk Score** | 15 (High) |
| **Category** | Product |

**Consequences**:
- Low adoption rates
- High churn after first use
- Negative reviews citing complexity
- Core value proposition fails

**Mitigation Strategies**:
1. **User testing**: Test with non-tech-savvy users early and often
2. **Progressive disclosure**: Hide advanced features until needed
3. **Onboarding flow**: Guided first-time experience
4. **Simplify ruthlessly**: Cut features that add complexity without clear value
5. **Feedback loops**: In-app feedback mechanism

**Contingency**:
- Simplify post-launch based on feedback
- Create "lite" mode with reduced features

**Owner**: Product Lead
**Status**: Open

---

### P2: Low Invite Conversion

| Attribute | Value |
|-----------|-------|
| **Description** | The app depends on viral growth (members inviting others). If invite conversion is low, communities won't reach critical mass. |
| **Likelihood** | 3 (Possible) |
| **Impact** | 4 (Major) |
| **Risk Score** | 12 (High) |
| **Category** | Product |

**Consequences**:
- Communities stagnate with 1-2 members
- Value proposition not realized
- Negative word of mouth
- Growth stalls

**Mitigation Strategies**:
1. **Frictionless invite**: One-tap share, clear messaging
2. **Multiple channels**: Code, link, QR, text, email
3. **Onboarding for invitees**: Explain value before signup
4. **Reminder to invite**: Prompt organizers to invite more
5. **A/B test messaging**: Optimize invite copy

**Contingency**:
- Reduce friction further (guest access without account?)
- Marketing push to acquire community organizers

**Owner**: Product Lead
**Status**: Open

---

### P3: Feature Parity Expectations

| Attribute | Value |
|-----------|-------|
| **Description** | Users may expect features from competitors (TeamSnap scheduling, Splitwise details, Google Calendar integration) that we don't have in MVP. |
| **Likelihood** | 4 (Likely) |
| **Impact** | 2 (Minor) |
| **Risk Score** | 8 (Medium) |
| **Category** | Product |

**Consequences**:
- Users churn to familiar tools
- Negative reviews citing missing features
- Comparison shopping goes against us

**Mitigation Strategies**:
1. **Focus on integration**: Our value is all-in-one, not feature-for-feature parity
2. **Set expectations**: Clear messaging about what we do/don't do
3. **Roadmap transparency**: Show what's coming
4. **Quick iteration**: Ship requested features fast post-launch
5. **Feedback collection**: Prioritize based on actual user requests

**Contingency**:
- Accelerate high-demand features
- Consider integrations with existing tools as bridges

**Owner**: Product Lead
**Status**: Open

---

### P4: Single Platform Limitation

| Attribute | Value |
|-----------|-------|
| **Description** | iOS-only launch excludes Android users. Mixed-platform families/teams cannot fully adopt. |
| **Likelihood** | 5 (Almost Certain) |
| **Impact** | 3 (Moderate) |
| **Risk Score** | 15 (High) |
| **Category** | Product |

**Consequences**:
- Families with Android users can't fully participate
- Teams exclude Android-using parents
- Market size reduced by ~50%
- Negative reviews from excluded users

**Mitigation Strategies**:
1. **Clear communication**: iOS-only stated upfront
2. **Android roadmap**: Commit to timeline (v1.5)
3. **Web viewer**: Consider read-only web access earlier
4. **Target iOS-heavy demographics**: Families with higher iOS penetration
5. **Waitlist**: Collect Android interest for launch notification

**Contingency**:
- Accelerate Android development if demand overwhelming
- Build React Native or Flutter for faster cross-platform

**Owner**: Product Lead
**Status**: Accepted (known limitation)

---

## Market Risks

### M1: Competitor Response

| Attribute | Value |
|-----------|-------|
| **Description** | Established competitors (BAND, TeamSnap, Splitwise) could improve their products or launch similar all-in-one features. |
| **Likelihood** | 3 (Possible) |
| **Impact** | 3 (Moderate) |
| **Risk Score** | 9 (Medium) |
| **Category** | Market |

**Consequences**:
- Harder to differentiate
- Users stay with existing tools
- Marketing costs increase

**Mitigation Strategies**:
1. **Move fast**: Launch before competitors react
2. **Focus on UX**: Execution matters more than features
3. **Community building**: Create loyal user base early
4. **Privacy positioning**: Competitors can't easily match privacy-first
5. **Integration depth**: All-in-one is hard to replicate

**Contingency**:
- Double down on differentiators (privacy, simplicity)
- Consider acquisition or partnership

**Owner**: Founder
**Status**: Open

---

### M2: Apple Launches Competitor

| Attribute | Value |
|-----------|-------|
| **Description** | Apple could launch a family/group coordination feature in iOS (they have Family Sharing, Shared Albums, Reminders). Direct platform competition would be devastating. |
| **Likelihood** | 2 (Unlikely) |
| **Impact** | 5 (Severe) |
| **Risk Score** | 10 (High) |
| **Category** | Market |

**Consequences**:
- Built-in always wins on iOS
- App becomes redundant
- Investment lost

**Mitigation Strategies**:
1. **Multi-platform**: Android launch creates insurance
2. **Feature depth**: Go deeper than Apple typically does
3. **Community focus**: Sports teams, clubs (not just families)
4. **Cross-platform value**: Families with mixed devices
5. **Monitor WWDC**: Adjust strategy if Apple announces

**Contingency**:
- Pivot to Android-first if Apple enters market
- Focus on use cases Apple ignores (sports teams, finances)

**Owner**: Founder
**Status**: Monitor

---

### M3: Economic Downturn

| Attribute | Value |
|-----------|-------|
| **Description** | Recession could reduce discretionary spending. Subscription apps are often first to be cut. |
| **Likelihood** | 2 (Unlikely) |
| **Impact** | 3 (Moderate) |
| **Risk Score** | 6 (Medium) |
| **Category** | Market |

**Consequences**:
- Lower conversion to paid
- Higher churn
- Reduced marketing effectiveness

**Mitigation Strategies**:
1. **Low price point**: Keep subscription affordable ($4.99-9.99)
2. **Clear ROI**: Show value vs. alternatives
3. **Free tier**: Generous free tier retains users
4. **Essential positioning**: Coordination tools, not luxury
5. **Cost efficiency**: Keep burn low

**Contingency**:
- Reduce pricing
- Extend free tier
- Focus on retention over acquisition

**Owner**: Founder
**Status**: Monitor

---

## Security & Privacy Risks

### S1: Data Breach

| Attribute | Value |
|-----------|-------|
| **Description** | Unauthorized access to user data (personal info, financial data, communications) could occur through API vulnerabilities, compromised credentials, or insider threat. |
| **Likelihood** | 2 (Unlikely) |
| **Impact** | 5 (Severe) |
| **Risk Score** | 10 (High) |
| **Category** | Security |

**Consequences**:
- User trust destroyed
- Legal liability (GDPR fines up to 4% revenue)
- Negative press
- Potential shutdown

**Mitigation Strategies**:
1. **Security review**: Professional security audit before launch
2. **Encryption**: TLS everywhere, encrypted at rest
3. **Access control**: Principle of least privilege
4. **Audit logging**: Track all data access
5. **Incident response plan**: Document response procedures
6. **Penetration testing**: Before launch and periodically

**Contingency**:
- Incident response plan with communication templates
- Cyber insurance

**Owner**: Security Lead
**Status**: Open

---

### S2: Authentication Bypass

| Attribute | Value |
|-----------|-------|
| **Description** | Vulnerabilities in auth flow could allow unauthorized access to accounts or communities. |
| **Likelihood** | 2 (Unlikely) |
| **Impact** | 5 (Severe) |
| **Risk Score** | 10 (High) |
| **Category** | Security |

**Consequences**:
- Account takeovers
- Unauthorized community access
- Privacy violations

**Mitigation Strategies**:
1. **Use Azure AD B2C**: Battle-tested auth service
2. **Token validation**: Strict JWT validation on every request
3. **Session management**: Secure token storage, expiration
4. **Rate limiting**: Prevent brute force
5. **Security testing**: Auth-specific penetration tests

**Contingency**:
- Force password reset if breach suspected
- Revoke all tokens and require re-auth

**Owner**: Security Lead
**Status**: Open

---

### S3: Privacy Violation (Accidental)

| Attribute | Value |
|-----------|-------|
| **Description** | Bug or misconfiguration could expose private content to wrong users (e.g., showing Community A's posts in Community B). |
| **Likelihood** | 2 (Unlikely) |
| **Impact** | 4 (Major) |
| **Risk Score** | 8 (Medium) |
| **Category** | Security |

**Consequences**:
- Private family content exposed
- User trust violated
- Potential legal issues

**Mitigation Strategies**:
1. **Row-level security**: PostgreSQL RLS as second defense
2. **Query scoping**: All queries include community_id filter
3. **Testing**: Automated tests for data isolation
4. **Code review**: Security-focused review for data access
5. **Monitoring**: Alert on anomalous data access patterns

**Contingency**:
- Immediate hotfix capability
- Affected user notification process

**Owner**: Backend Lead
**Status**: Open

---

### S4: Credential Exposure

| Attribute | Value |
|-----------|-------|
| **Description** | API keys, database passwords, or other secrets could be accidentally committed to git, logged, or exposed in error messages. |
| **Likelihood** | 3 (Possible) |
| **Impact** | 4 (Major) |
| **Risk Score** | 12 (High) |
| **Category** | Security |

**Consequences**:
- Unauthorized access to infrastructure
- Data breach via exposed credentials
- Service disruption

**Mitigation Strategies**:
1. **Azure Key Vault**: All secrets in vault, not code
2. **Git hooks**: Pre-commit scanning for secrets
3. **.gitignore**: Ensure .env files never committed
4. **Error sanitization**: Never log secrets or credentials
5. **Rotation**: Regular credential rotation

**Contingency**:
- Immediate rotation of exposed credentials
- Audit logs review for unauthorized access

**Owner**: Backend Lead
**Status**: Open

---

## Operational Risks

### O1: Azure Service Outage

| Attribute | Value |
|-----------|-------|
| **Description** | Azure services (App Service, PostgreSQL, Blob Storage) could experience outages, making app unavailable. |
| **Likelihood** | 2 (Unlikely) |
| **Impact** | 4 (Major) |
| **Risk Score** | 8 (Medium) |
| **Category** | Operational |

**Consequences**:
- App unusable during outage
- User frustration
- Missed events/communications

**Mitigation Strategies**:
1. **Offline mode**: App functional without backend
2. **Azure status monitoring**: Subscribe to Azure status alerts
3. **Multi-region consideration**: Future-proof architecture
4. **Graceful degradation**: Clear messaging when backend unavailable
5. **SLA selection**: Choose appropriate Azure SLA tiers

**Contingency**:
- Status page for users
- Communication templates for outage notifications

**Owner**: DevOps
**Status**: Open

---

### O2: App Store Rejection

| Attribute | Value |
|-----------|-------|
| **Description** | Apple could reject the app for guideline violations, delaying launch. Common issues: payment flows, data collection, privacy. |
| **Likelihood** | 3 (Possible) |
| **Impact** | 3 (Moderate) |
| **Risk Score** | 9 (Medium) |
| **Category** | Operational |

**Consequences**:
- Launch delayed by 1-2 weeks per rejection
- Rework required
- Marketing timing disrupted

**Mitigation Strategies**:
1. **Guideline compliance**: Review all guidelines before submission
2. **Stripe web checkout**: Avoid IAP guideline issues for subscriptions
3. **Privacy nutrition labels**: Complete accurately
4. **TestFlight first**: Beta test before production submission
5. **Appeal preparation**: Know appeal process

**Contingency**:
- Budget 2 rejection cycles in timeline
- Have expedited review request ready

**Owner**: iOS Lead
**Status**: Open

---

### O3: Scaling Issues at Launch

| Attribute | Value |
|-----------|-------|
| **Description** | If launch exceeds expected traffic, infrastructure may not scale quickly enough, causing slowdowns or outages. |
| **Likelihood** | 2 (Unlikely) |
| **Impact** | 3 (Moderate) |
| **Risk Score** | 6 (Medium) |
| **Category** | Operational |

**Consequences**:
- Slow app performance
- Failed requests
- Negative first impressions
- User churn

**Mitigation Strategies**:
1. **Load testing**: Test 2-3x expected load before launch
2. **Auto-scaling**: Configure Azure auto-scale rules
3. **CDN for static content**: Reduce origin load
4. **Database connection pooling**: Handle connection spikes
5. **Monitoring**: Real-time dashboards for traffic/performance

**Contingency**:
- Manual scale-up on high traffic
- Rate limiting to protect core functionality

**Owner**: DevOps
**Status**: Open

---

## Financial Risks

### F1: Azure Costs Exceed Budget

| Attribute | Value |
|-----------|-------|
| **Description** | Cloud costs could exceed projections due to unexpected usage patterns, inefficient code, or pricing changes. |
| **Likelihood** | 3 (Possible) |
| **Impact** | 2 (Minor) |
| **Risk Score** | 6 (Medium) |
| **Category** | Financial |

**Consequences**:
- Higher burn rate
- Need to raise prices or cut features
- Infrastructure constraints

**Mitigation Strategies**:
1. **Cost alerts**: Azure budget alerts at 50%, 80%, 100%
2. **Reserved instances**: Commit for discounts when stable
3. **Right-sizing**: Regular review of resource utilization
4. **Storage lifecycle**: Auto-archive old data
5. **CDN optimization**: Cache effectively to reduce origin calls

**Contingency**:
- Reduce storage limits
- Optimize expensive queries
- Consider alternative hosting

**Owner**: Founder
**Status**: Open

---

### F2: Low Conversion to Paid

| Attribute | Value |
|-----------|-------|
| **Description** | Users may not convert from free to paid tier, resulting in insufficient revenue to sustain operations. |
| **Likelihood** | 3 (Possible) |
| **Impact** | 4 (Major) |
| **Risk Score** | 12 (High) |
| **Category** | Financial |

**Consequences**:
- Revenue below projections
- Cannot fund continued development
- May need to shut down or sell

**Mitigation Strategies**:
1. **Clear value proposition**: Paid features must be compelling
2. **Appropriate limits**: Free tier useful but limited
3. **Upgrade prompts**: Non-annoying reminders of paid features
4. **Price testing**: A/B test price points
5. **Annual plans**: Offer discount for annual commitment

**Contingency**:
- Reduce free tier limits
- Add more premium features
- Consider advertising (last resort, contradicts privacy positioning)

**Owner**: Founder
**Status**: Open

---

## Legal & Compliance Risks

### L1: GDPR Non-Compliance

| Attribute | Value |
|-----------|-------|
| **Description** | Failure to comply with GDPR could result in fines and required changes. Applies to EU users regardless of company location. |
| **Likelihood** | 2 (Unlikely) |
| **Impact** | 4 (Major) |
| **Risk Score** | 8 (Medium) |
| **Category** | Legal |

**Consequences**:
- Fines up to €20M or 4% of revenue
- Required product changes
- Reputation damage

**Mitigation Strategies**:
1. **Data export**: Implement user data export (Article 20)
2. **Right to deletion**: Implement account deletion (Article 17)
3. **Consent**: Clear consent for data processing
4. **Privacy policy**: Clear, accurate policy
5. **Data minimization**: Only collect necessary data
6. **Legal review**: Have privacy lawyer review

**Contingency**:
- Block EU users if cannot comply (not recommended)
- Engage GDPR specialist for remediation

**Owner**: Founder
**Status**: Open

---

### L2: COPPA Violation

| Attribute | Value |
|-----------|-------|
| **Description** | Children under 13 may use the app (family members, Little League players). COPPA requires parental consent for data collection from children. |
| **Likelihood** | 3 (Possible) |
| **Impact** | 4 (Major) |
| **Risk Score** | 12 (High) |
| **Category** | Legal |

**Consequences**:
- FTC fines
- Required product changes
- App Store removal

**Mitigation Strategies**:
1. **Age gate**: Require 13+ to create account
2. **Family members model**: Children represented by parent, no child accounts
3. **No child data collection**: Children have no login, no direct data
4. **Privacy policy**: Clearly address children's privacy
5. **Legal review**: Confirm compliance approach

**Contingency**:
- Remove family members feature if compliance unclear
- Require age verification

**Owner**: Founder
**Status**: Open

---

### L3: Financial Services Regulation

| Attribute | Value |
|-----------|-------|
| **Description** | Money-related features (expense tracking, dues) could potentially be considered financial services, triggering regulatory requirements. |
| **Likelihood** | 2 (Unlikely) |
| **Impact** | 4 (Major) |
| **Risk Score** | 8 (Medium) |
| **Category** | Legal |

**Consequences**:
- Licensing requirements
- Compliance costs
- Feature restrictions

**Mitigation Strategies**:
1. **No money handling**: We track expenses, not process payments
2. **Deep links only**: Venmo/Apple Pay handles actual money
3. **Clear language**: "Expense tracker" not "payment platform"
4. **Legal review**: Confirm we're not a money transmitter
5. **State-by-state review**: Some states stricter than others

**Contingency**:
- Remove financial features in problematic jurisdictions
- Partner with licensed provider

**Owner**: Founder
**Status**: Open

---

## Risk Register Summary

### Critical Risks (Score 16-25)

| ID | Risk | Score | Owner | Status |
|----|------|-------|-------|--------|
| T1 | Offline sync complexity | 16 | iOS Lead | Open |

### High Risks (Score 10-15)

| ID | Risk | Score | Owner | Status |
|----|------|-------|-------|--------|
| T2 | Azure AD B2C complexity | 15 | Backend Lead | Open |
| T3 | Push notification reliability | 12 | Backend Lead | Open |
| P1 | Too complex for users | 15 | Product Lead | Open |
| P2 | Low invite conversion | 12 | Product Lead | Open |
| P4 | Single platform limitation | 15 | Product Lead | Accepted |
| M2 | Apple launches competitor | 10 | Founder | Monitor |
| S1 | Data breach | 10 | Security Lead | Open |
| S2 | Authentication bypass | 10 | Security Lead | Open |
| S4 | Credential exposure | 12 | Backend Lead | Open |
| F2 | Low conversion to paid | 12 | Founder | Open |
| L2 | COPPA violation | 12 | Founder | Open |

### Medium Risks (Score 5-9)

| ID | Risk | Score | Owner | Status |
|----|------|-------|-------|--------|
| T4 | Vapor ecosystem limitations | 9 | Backend Lead | Open |
| T5 | SwiftData maturity | 9 | iOS Lead | Open |
| T6 | Image/media performance | 6 | iOS Lead | Open |
| P3 | Feature parity expectations | 8 | Product Lead | Open |
| M1 | Competitor response | 9 | Founder | Open |
| M3 | Economic downturn | 6 | Founder | Monitor |
| S3 | Privacy violation (accidental) | 8 | Backend Lead | Open |
| O1 | Azure service outage | 8 | DevOps | Open |
| O2 | App Store rejection | 9 | iOS Lead | Open |
| O3 | Scaling issues at launch | 6 | DevOps | Open |
| F1 | Azure costs exceed budget | 6 | Founder | Open |
| L1 | GDPR non-compliance | 8 | Founder | Open |
| L3 | Financial services regulation | 8 | Founder | Open |

---

## Monitoring & Review

### Risk Review Cadence

| Frequency | Activity |
|-----------|----------|
| Weekly | Review critical and high risks in team standup |
| Bi-weekly | Full risk register review |
| Monthly | Risk scoring reassessment |
| Quarterly | Comprehensive risk audit |

### Risk Indicators to Monitor

| Risk | Indicator | Threshold |
|------|-----------|-----------|
| T1: Sync issues | Sync failure rate | > 1% |
| T3: Push reliability | Push delivery rate | < 95% |
| P1: Complexity | Onboarding completion rate | < 70% |
| P2: Invite conversion | Invite → signup rate | < 30% |
| S1: Security | Failed login attempts | Spike > 10x normal |
| F2: Conversion | Free → paid conversion | < 3% after 3 months |

### Escalation Process

1. **Risk owner** identifies risk materialization
2. **Immediate mitigation** steps executed
3. **Team notification** within 1 hour
4. **Contingency activation** if mitigation fails
5. **Post-incident review** within 1 week

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 2026 | Claude | Initial draft |

---

*This completes the OrbitCove planning documentation suite.*
