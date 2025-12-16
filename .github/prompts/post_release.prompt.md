# Post-Release Finalization

## Instructions
This prompt finalizes the release after completing the release preparation. Execute these steps to merge and tag the release.

## Step 0: Check for Uncommitted Changes
Before starting the merge process, verify there are no uncommitted changes:

1. **Check Git Status**:
   ```
   git status
   ```

2. **If there are uncommitted changes**:
   - Ask if these changes should be committed to the release branch
   - If yes: Commit them with appropriate message
   - If no: Stash or discard as appropriate

3. **Ensure working tree is clean** before proceeding to Step 1

## Step 1: Complete Git Release Workflow
Execute the git release workflow after completing the release preparation:

1. **Merge to Master**:
   ```
   git checkout master
   git merge release/[VERSION]
   ```

2. **Create and Push Tag**:
   ```
   git tag [VERSION]
   git push origin master
   git push origin [VERSION]
   ```
   
   **Note**: Tags use the format `1.2.0` (without "v" prefix) to match existing tag convention.

3. **Clean Up Release Branch**:
   ```
   git branch -d release/[VERSION]
   git push origin --delete release/[VERSION]
   ```

4. **Verify Completion**:
   ```
   git status
   git tag --sort=-version:refname
   ```

## Step 2: Verify Release Completion
- Confirm you are on master branch
- Verify latest tag matches released version
- Ensure release branch has been cleaned up
- Check that working tree is clean

## Expected Outcome
After execution:
- Release branch merged to master with tag
- Clean repository state on master branch
- Release is finalized and tagged on GitHub

**🎉 Release is now complete and tagged on GitHub!**

You can now:
- Create a GitHub release if desired
- Start working on the next version when ready

---

**Execute this post-release finalization now to complete the release.**