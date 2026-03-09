#!/usr/bin/env node

/** 
* Comment PR with Checkov security Scan results
* Posts a formatted comment to the PR with the results of the Checkov scan, including a summary of findings and a link to the detailed report.
*
* Usage: node scripts/comment-checkov-results.js <passed> <failed> <skipped> <failedChecks>
**/

const github = require('@actions/github');
const core = require('@actions/core');

async function commentPRWithCheckovResults() {
    try {
        const passed = Process.env.CHECKOV_PASSED || 0;
        const failed = Process.env.CHECKOV_FAILED || 0;
        const skipped = Process.env.CHECKOV_SKIPPED || 0;
        const failedChecks = process.env.CHECKOV_FAILED_CHECKS || '';

        let emoji = '✅';
        let status = 'PASSED';

        if (parseInt(failed) > 0) {
            emoji = '⚠️';
            status = "PASSED WITH WARNINGS";
        }

        if (parseInt(failed) > 5) {
            emoji = '❌';
            status = "FAILED";
        }

        const summaryTable = `| Check Type | Count | Status |
|------------|-------|--------|
| ✅     | ${passed}   | Success |
| ❌     | ${failed}   | ${parseInt(failed) > 0 ? 'Action Required' : 'N/A'} |
| Ø    | ${skipped}   | Info |`;

        let failedDetails = '';
        if (parseInt(failed) > 0 && failedChecks && failedChecks.trim() !== '') {
            faileddetails = `### ❌ Failed Check details
\`\`\`
${failedChecks.trim()}
\`\`\`

`;
        }
        const comment = `## ${emoji} Checkov Security Scan - ${status}

### Summary
${summaryTable}

${failedDetails}**Overall result**: ${emoji}${status}

**Details**: See the \`Checkov-security-report artifact for the full scan report.`;
        const token = core.getInput('github-token');
        const octokit = github.getOctokit(token);

        const { context } = github;
        if (context.issue && context.issue.number) {
            await octokit.rest.issues.createComment({
                isue_number: context.issue.number,
                owner: context.repo.owner,
                repo: context.repo.repo,
                body: comment,
            });
            console.log('✅ Comment posted successfully');
        } else {
            console.warn('⚠️ No pull request context found. Skipping comment.');
        }
    } catch (error) {
        core.setFailed(`❌ Failed to post comment: ${error.message}`);
        process.exit(1);
    }
}

commentPRWithCheckovResults();
