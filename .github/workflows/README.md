# 🤖 Pickly GitHub Actions Workflows

**PRD v9.6.1 - Phase 4D Step 2**

Automated CI/CD workflows for the Pickly data pipeline.

---

## 📋 Available Workflows

### 🔄 Data Sync Pipeline (`data-sync.yml`)

Automated API collection and data transformation workflow.

**Schedule**: Daily at 3:00 AM KST (18:00 UTC)

**Triggers**:
- ⏰ Scheduled (cron): `0 18 * * *`
- 🖱️ Manual (workflow_dispatch): Via GitHub UI or API

**Steps**:
1. Checkout repository
2. Setup Node.js v22
3. Install dependencies
4. Verify environment variables
5. Run API collection (`npm run collect:api`)
6. Run data transformation (`npm run transform:api`)
7. Upload execution logs as artifacts
8. Generate summary report
9. Notify on failure (optional)

---

## 🚀 Setup Instructions

### 1️⃣ Configure GitHub Secrets

Navigate to: **Repository Settings → Secrets and variables → Actions**

Add the following secrets:

| Secret Name | Description | Required |
|-------------|-------------|----------|
| `SUPABASE_URL` | Supabase project URL | ✅ Yes |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key (bypasses RLS) | ✅ Yes |
| `SUPABASE_ANON_KEY` | Anon key (fallback) | ⚠️ Recommended |

**Example values**:
```
SUPABASE_URL: https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 2️⃣ Enable Workflows

1. Go to **Actions** tab
2. Enable workflows for this repository
3. Select **🔄 Pickly Data Sync Pipeline**
4. Click **Enable workflow**

### 3️⃣ Test Manual Run

1. Go to **Actions** tab
2. Select **🔄 Pickly Data Sync Pipeline**
3. Click **Run workflow**
4. (Optional) Check **dry_run** for testing
5. Click **Run workflow**

---

## 🎮 Manual Execution

### Via GitHub UI

1. Navigate to: **Actions → 🔄 Pickly Data Sync Pipeline**
2. Click **Run workflow** button
3. Select branch (usually `main`)
4. Toggle **dry_run** if testing
5. Click **Run workflow**

### Via GitHub CLI

```bash
# Normal execution
gh workflow run data-sync.yml

# Dry run mode (test without DB writes)
gh workflow run data-sync.yml -f dry_run=true

# Check workflow status
gh run list --workflow=data-sync.yml

# View workflow logs
gh run view --log
```

### Via GitHub API

```bash
# Trigger workflow
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/repos/OWNER/REPO/actions/workflows/data-sync.yml/dispatches \
  -d '{"ref":"main","inputs":{"dry_run":"false"}}'
```

---

## 📊 Monitoring & Logs

### View Workflow Runs

**GitHub UI**: **Actions** tab → **🔄 Pickly Data Sync Pipeline**

**GitHub CLI**:
```bash
# List recent runs
gh run list --workflow=data-sync.yml --limit 10

# View specific run
gh run view <run-id>

# View logs
gh run view <run-id> --log
```

### Download Artifacts

Execution logs are uploaded as artifacts after each run.

**GitHub UI**: Workflow run page → **Artifacts** section

**GitHub CLI**:
```bash
# List artifacts
gh run view <run-id> --log

# Download artifact
gh run download <run-id> -n execution-logs-<run-number>
```

### Summary Reports

Each workflow run generates a summary with:
- Execution times for each step
- Success/failure status
- Artifact information
- Database verification instructions

**View**: Workflow run page → **Summary** tab

---

## 🧪 Testing

### Dry Run Mode

Test without writing to database:

```bash
# Via GitHub CLI
gh workflow run data-sync.yml -f dry_run=true

# Via GitHub UI
Actions → Run workflow → Check "dry_run" → Run
```

**Expected output**:
- ✅ All steps execute
- 🧪 No database writes
- 📋 Logs show "DRY RUN mode"

### Local Testing

Test the workflow locally using [act](https://github.com/nektos/act):

```bash
# Install act
brew install act  # macOS
# or
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run workflow locally
cd /path/to/pickly_service
act workflow_dispatch -W .github/workflows/data-sync.yml

# Dry run mode
act workflow_dispatch -W .github/workflows/data-sync.yml \
  -i dry_run=true
```

---

## 🔧 Troubleshooting

### Workflow Fails on Environment Variables

**Problem**: "ERROR: SUPABASE_URL is not set"

**Solution**:
1. Verify secrets in **Settings → Secrets → Actions**
2. Ensure secret names match exactly (case-sensitive)
3. Re-run workflow after adding secrets

### Workflow Fails on Collection

**Problem**: "API Collection failed with exit code 1"

**Solution**:
1. Check API sources in database are active
2. Verify API endpoints are accessible
3. Check API keys are valid
4. Review logs artifact for detailed errors

### Workflow Timeout

**Problem**: Workflow exceeds 30-minute timeout

**Solution**:
1. Reduce number of active API sources
2. Optimize collection/transformation logic
3. Increase timeout in workflow file:
   ```yaml
   timeout-minutes: 60  # Increase from 30
   ```

### Dependencies Installation Fails

**Problem**: "npm ci" fails

**Solution**:
1. Verify `package-lock.json` exists in backend/
2. Check Node.js version compatibility
3. Try removing cache:
   ```yaml
   # Remove cache line temporarily
   # cache: 'npm'
   ```

---

## 📈 Performance Metrics

### Typical Execution Times

| Step | Duration | Notes |
|------|----------|-------|
| Checkout | ~5s | Depends on repo size |
| Setup Node | ~10s | Cached after first run |
| Install Deps | ~15s | Cached with package-lock.json |
| API Collection | ~30s | Depends on API sources |
| Transformation | ~10s | Depends on raw data volume |
| **Total** | **~70s** | Typical run time |

### Optimization Tips

1. **Cache Dependencies**: Enabled by default
2. **Minimize API Sources**: Only collect what's needed
3. **Batch Processing**: Transform in batches
4. **Parallel Jobs**: Split into multiple workflows if needed

---

## 🔔 Notifications (Optional)

### Slack Notifications

Add to workflow (step 9):

```yaml
- name: 🚨 Send Slack Notification
  if: failure()
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
  run: |
    curl -X POST -H 'Content-type: application/json' \
      --data "{
        \"text\": \"❌ Pickly Data Sync Failed!\",
        \"blocks\": [{
          \"type\": \"section\",
          \"text\": {
            \"type\": \"mrkdwn\",
            \"text\": \"*Pickly Data Sync Pipeline Failed*\\nWorkflow: <${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}|View Logs>\"
          }
        }]
      }" \
      $SLACK_WEBHOOK_URL
```

**Setup**:
1. Create Slack webhook URL
2. Add to repository secrets as `SLACK_WEBHOOK_URL`

### Email Notifications

GitHub sends email notifications automatically for:
- Workflow failures (if you're watching the repo)
- First workflow success after failures

**Configure**: **Profile → Settings → Notifications → Actions**

---

## 🔒 Security Best Practices

### Secrets Management

✅ **DO**:
- Use GitHub Secrets for sensitive data
- Rotate keys regularly
- Use service role keys with minimal permissions
- Enable secret scanning

❌ **DON'T**:
- Hardcode secrets in workflow files
- Echo secrets in logs
- Commit `.env` files
- Share secrets publicly

### Workflow Permissions

Current permissions (default):
- ✅ Read repository contents
- ✅ Write artifacts
- ❌ No write access to code

**Principle of least privilege**: Only grant necessary permissions.

---

## 📚 Related Documentation

- **Data Sync Workflow**: `.github/workflows/data-sync.yml`
- **Phase 4D Step 1**: `docs/PHASE4D_STEP1_CRON_SCHEDULER_COMPLETE.md`
- **Phase 4D Step 2**: `docs/PHASE4D_STEP2_GITHUB_ACTIONS_COMPLETE.md`
- **API Collector**: `backend/services/api-collector/README.md`
- **Data Transformer**: `backend/services/data-transformer/README.md`
- **PRD v9.6.1**: `docs/prd/PRD_CURRENT.md`

---

## 🆘 Support

### GitHub Actions Issues

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Status](https://www.githubstatus.com/)

### Pickly Support

- Check logs artifact for detailed error messages
- Review Supabase dashboard for database issues
- Consult PRD v9.6.1 for requirements

---

**Version**: 1.0.0
**Last Updated**: 2025-11-02
**Status**: Production Ready ✅
