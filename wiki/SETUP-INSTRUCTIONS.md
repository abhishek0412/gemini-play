# GitHub Wiki Setup Instructions

This document provides step-by-step instructions for setting up the comprehensive wiki for the **gemini-play** project on GitHub.

## 📋 Wiki Pages Created

The following wiki pages have been prepared for your project:

1. **Home.md** - Main landing page with project overview and navigation
2. **Quick-Start.md** - 5-minute setup guide for new contributors
3. **Compliance-Framework.md** - Detailed policy-as-code documentation
4. **Terraform.md** - Infrastructure deployment with Terraform
5. **Known-Issues.md** - Bug reports and improvement opportunities

## 🚀 Setting Up the GitHub Wiki

### Step 1: Enable Wiki for Your Repository

1. Navigate to your repository: https://github.com/abhishek0412/gemini-play
2. Click on **Settings** tab
3. Scroll down to **Features** section
4. Check the **✅ Wikis** checkbox if not already enabled
5. Click **Save changes**

### Step 2: Access the Wiki Section

1. Go to your repository homepage
2. Click on the **Wiki** tab (should appear next to Issues, Pull requests, etc.)
3. You'll see a "Create the first page" button

### Step 3: Create Wiki Pages

For each wiki page, follow these steps:

#### Creating the Home Page

1. Click **"Create the first page"** or **"New Page"**
2. Set the page title as: **Home**
3. Copy the content from `wiki/Home.md` and paste it into the wiki editor
4. Click **Save Page**

#### Creating Additional Pages

Repeat for each additional page:

1. Click **"New Page"** button
2. Use these exact titles:
   - **Quick-Start**
   - **Compliance-Framework** 
   - **Terraform**
   - **Known-Issues**
3. Copy content from respective `.md` files in the `wiki/` directory
4. Click **Save Page** for each

### Step 4: Verify Wiki Navigation

After creating all pages, verify that:
1. All internal links work (links like `[[Quick Start Guide|Quick-Start]]`)
2. The navigation menu shows all pages
3. Images and badges display correctly
4. Code blocks are properly formatted

## 📁 Wiki Content Files

The wiki content is available in these local files:

```
wiki/
├── Home.md                    # Main landing page
├── Quick-Start.md            # Getting started guide  
├── Compliance-Framework.md   # Policy-as-code documentation
├── Terraform.md             # Infrastructure guide
├── Known-Issues.md          # Bug reports and issues
└── SETUP-INSTRUCTIONS.md    # This file
```

## 🎨 Wiki Features Used

The wiki pages utilize these GitHub Wiki features:

- **Markdown formatting** - Headers, lists, code blocks, tables
- **Mermaid diagrams** - Architecture and flow diagrams
- **Internal linking** - Cross-references between wiki pages
- **Badges** - Status and technology badges
- **Code syntax highlighting** - Bash, HCL, YAML, etc.
- **Collapsible sections** - Organized content structure

## 🔗 Internal Link Structure

The wiki uses this internal linking pattern:

```markdown
[[Display Text|Page-Name]]
```

Examples:
- `[[Quick Start Guide|Quick-Start]]` → Links to Quick-Start page
- `[[Compliance Framework|Compliance-Framework]]` → Links to Compliance-Framework page
- `[[Known Issues|Known-Issues]]` → Links to Known-Issues page

## 📝 Content Highlights

### Home Page Features
- Project overview and architecture diagram
- Navigation menu with all wiki pages
- Quick command reference
- Project statistics table
- Support links

### Quick Start Features
- 5-minute setup guide
- Platform-specific installation instructions
- Step-by-step verification process
- Common troubleshooting solutions

### Compliance Framework Features
- Comprehensive policy documentation
- Usage examples and sample output
- Customization guides
- Integration instructions

### Terraform Guide Features
- Complete infrastructure walkthrough
- Security recommendations
- State management best practices
- CI/CD integration examples

### Known Issues Features
- Categorized bug reports (Critical, High, Medium, Low)
- Detailed reproduction steps
- Recommended fixes with code examples
- Resolution roadmap

## 🔄 Maintaining the Wiki

### Regular Updates

Update the wiki when:
- New features are added to the project
- Issues are resolved (update Known-Issues page)
- Infrastructure changes are made
- Compliance policies are modified

### Content Guidelines

Follow these guidelines for wiki content:
- Use consistent formatting and structure
- Include code examples for all procedures
- Keep navigation links up to date
- Add screenshots for complex procedures
- Version control important changes

### Automation Opportunities

Consider these automation options:
- **Auto-sync**: Use GitHub Actions to sync wiki with repository files
- **Issue tracking**: Link wiki updates to GitHub issues
- **Version badges**: Auto-update version badges in documentation

## 🛠️ Troubleshooting Wiki Setup

### Common Issues

**Wiki tab not visible**
- Check repository settings → Features → Enable Wikis

**Links not working**
- Ensure page names match exactly (case-sensitive)
- Use hyphens instead of spaces in page names

**Diagrams not rendering**
- GitHub Wiki supports Mermaid diagrams
- Verify diagram syntax is correct

**Formatting issues**
- GitHub Wiki uses GitHub Flavored Markdown
- Some advanced markdown features may not work

### Testing Links

After setup, test these key navigation paths:
1. Home → Quick Start → Back to Home
2. Home → Compliance Framework → Security Policies
3. Known Issues → Issue details → Resolution steps
4. Terraform → Security Enhancements → Back to Terraform

## 📚 Alternative Setup Methods

### Method 1: Manual Copy-Paste (Recommended)
- Copy content from each `.md` file
- Paste directly into GitHub Wiki editor
- Best for initial setup

### Method 2: Clone Wiki Repository
```bash
# GitHub wikis are Git repositories
git clone https://github.com/abhishek0412/gemini-play.wiki.git
cd gemini-play.wiki
# Copy files and push
```

### Method 3: GitHub API (Advanced)
```bash
# Use GitHub API to create pages programmatically
# Requires GitHub Personal Access Token
```

## 🎯 Next Steps After Setup

1. **Test all wiki pages** - Verify content displays correctly
2. **Update README** - Add link to wiki in main repository README
3. **Share with team** - Notify collaborators about new documentation
4. **Set up maintenance** - Schedule regular wiki updates
5. **Gather feedback** - Ask users for documentation improvement suggestions

## 📞 Support

If you need help setting up the wiki:

1. **GitHub Documentation**: [About Wikis](https://docs.github.com/en/communities/documenting-your-project-with-wikis/about-wikis)
2. **Markdown Guide**: [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/)
3. **Issues**: Create an issue in the repository for wiki-specific problems

---

*Once the wiki is set up, you can delete this `wiki/` directory from your repository as the content will live in the GitHub Wiki system.*
