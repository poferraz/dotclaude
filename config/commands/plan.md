---
description: Restate requirements, assess risks, and create step-by-step implementation plan. WAIT for user CONFIRM before touching any code.
---

# Plan Command

This command invokes the **planner** agent to create a comprehensive implementation plan before writing any code.

## What This Command Does

1. **Restate Requirements** - Clarify what needs to be built
2. **Identify Risks** - Surface potential issues and blockers
3. **Create Step Plan** - Break down implementation into phases
4. **Wait for Confirmation** - MUST receive user approval before proceeding

## When to Use

Use `/plan` when:
- Starting a new feature
- Making significant architectural changes
- Working on complex refactoring
- Multiple files/components will be affected
- Requirements are unclear or ambiguous

## How It Works

The planner agent will:

1. **Analyze the request** and restate requirements in clear terms
2. **Break down into phases** with specific, actionable steps
3. **Identify dependencies** between components
4. **Assess risks** and potential blockers
5. **Estimate complexity** (High/Medium/Low)
6. **Present the plan** and WAIT for your explicit confirmation

## Example Usage

```
User: /plan I need to add email notifications when orders are completed

Agent (planner):
# Implementation Plan: Order Completion Email Notifications

## Requirements Restatement
- Send email notifications to users when their orders complete
- Support configurable notification preferences per user
- Ensure reliable delivery with retry on failure
- Include order summary and next steps in email body

## Implementation Phases

### Phase 1: Database Schema
- Add notification_preferences table: user_id, email_enabled, created_at
- Add notification_log table: id, user_id, order_id, type, status, sent_at
- Create indexes on user_id and order_id for performance

### Phase 2: Notification Service
- Create notification service in lib/notifications.ts
- Implement background job queue (e.g. BullMQ or pg-boss)
- Add retry logic for failed deliveries (3 attempts, exponential backoff)
- Create email templates

### Phase 3: Integration Points
- Hook into order completion logic (when status changes to "completed")
- Query user notification preferences before sending
- Enqueue notification job; worker handles delivery

### Phase 4: Frontend
- Add notification preferences toggle in user settings
- Show notification history in account page

## Dependencies
- Background job runner
- Transactional email service (Resend / Postmark / SendGrid)

## Risks
- HIGH: Email deliverability (SPF/DKIM setup required)
- MEDIUM: Job queue failure modes — need dead-letter queue
- LOW: Preference sync lag if preferences are cached

## Estimated Complexity: MEDIUM

**WAITING FOR CONFIRMATION**: Proceed with this plan? (yes/no/modify)
```

## Important Notes

**CRITICAL**: The planner agent will **NOT** write any code until you explicitly confirm the plan with "yes" or "proceed" or similar affirmative response.

If you want changes, respond with:
- "modify: [your changes]"
- "different approach: [alternative]"
- "skip phase 2 and do phase 3 first"

## Integration with Other Commands

After planning:
- Use `/tdd` to implement with test-driven development
- Use `/build-fix` if build errors occur
- Use `/code-review` to review completed implementation

## Related Agents

This command invokes the `planner` agent provided by ECC.

For manual installs, the source file lives at:
`agents/planner.md`
