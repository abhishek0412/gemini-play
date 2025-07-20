# Positive Validation: PR template should appear
1. Create a test branch:
   ```sh
   git checkout -b test/pr-template-validation
   echo "# Test file" > pr-template-test.md
   git add pr-template-test.md
   git commit -m "test: add file to validate PR template"
   git push origin test/pr-template-validation
   ```
2. Go to GitHub and open a new pull request from `test/pr-template-validation` to `master`.
3. Confirm that the PR description is auto-filled with the template.

# Negative Validation: PR template should NOT appear
1. Remove the template file:
   ```sh
   git checkout master
   git pull
   git rm .github/pull_request_template.md
   git commit -m "test: remove PR template for negative validation"
   git push origin master
   ```
2. Create a new branch and PR as above.
3. Confirm that the PR description is empty (no template).

# Restore the template after negative test if needed.
