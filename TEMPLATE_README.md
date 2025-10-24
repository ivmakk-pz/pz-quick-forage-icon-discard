# Mod Template Structure Created

## What's included:

### Core Mod Files (Contents/):
- B42 compliant folder structure
- mod.info template
- Basic Lua files (client, server, shared)
- Translation structure (EN)
- Sandbox options template

### Development Files:
- README.md template
- CHANGELOG.md template  
- LICENSE (MIT)
- .gitignore (minimal)
- workshop_assets/ folder
- .github/instructions & prompts (copied from existing project)

### Sample images included:
- icon.png (64x64)
- poster.png (512x512)  
- preview.png (256x256)
- thumb_01.jpg (1024x1024)

## How to Use This Template:

### Creating a New Mod Repository:

1. **Create local mod directory**:
   ```powershell
   # Create your new mod directory (recommended location for PZ mod development)
   # Use your actual mod name in PascalCase format (e.g., ForagingTooltipExtended)
   mkdir "C:\Users\{USERNAME}\Zomboid\Workshop\{YOUR_ACTUAL_MOD_NAME}"
   cd "C:\Users\{USERNAME}\Zomboid\Workshop\{YOUR_ACTUAL_MOD_NAME}"
   ```

2. **Download template files** (without git history):
   - Go to: https://github.com/ivmakk/pz-mod-template-ivmakk
   - Click "Code" → "Download ZIP"
   - Extract all files to your current mod directory

3. **Initialize fresh git repository**:
   ```powershell
   # Initialize new git repo (clean history)
   git init
   
   # Add remote origin (GitHub repo will be created automatically on first push)
   git remote add origin https://github.com/ivmakk/pz-{YOUR_ACTUAL_MOD_NAME}.git
   
   # Add all template files
   git add .
   git commit -m "Initial commit: Add mod template structure"
   
   # Push to your new repository (creates the repo automatically)
   git branch -M master
   git push -u origin master
   ```

4. **Customize the template**:
   - **Replace placeholders**: Search and replace all `{MOD_NAME}`, `{AUTHOR_NAME}`, etc.
   - **Replace images**: Update icon.png (64x64), poster.png (512x512), preview.png (256x256) with your mod's artwork
   - **Update mod.info**: Fill in actual mod metadata
   - **Customize Lua files**: Modify for your specific mod functionality
   - **Update README.md**: Replace with your mod's actual documentation

### Alternative: Using GitHub Template Feature

If this repository is marked as a template on GitHub:
1. Go to https://github.com/ivmakk/pz-mod-template-ivmakk
2. Click "Use this template" → "Create a new repository"
3. Name your new repository and create it
4. Clone your new repository locally:
   ```powershell
   git clone https://github.com/ivmakk/pz-{YOUR_ACTUAL_MOD_NAME}.git
   cd pz-{YOUR_ACTUAL_MOD_NAME}
   ```

## Template Variable Naming Convention

When using this template, replace the following variables according to these naming rules:

| Variable | Purpose | Naming Rule | Example |
|----------|---------|-------------|---------|
| `MOD_NAME_FULL` | Complete human-readable mod name | Exact title as shown to users | "Project Cook Extension Nutrients Sorting" |
| `MOD_NAME_BASE` | Extension mods only - parent mod name | Use only when extending another mod, skip for independent mods | "Project Cook Extension" |
| `MOD_NAME_CODE` | Folder/directory naming AND feature identifier | PascalCase concatenation, no spaces | "ProjectCookExtensionNutrientsSorting" |
| `MOD_PREFIX` | File prefix AND language namespace | 2-4 character abbreviation | "PCES" |
| `MOD_AUTHOR` | Creator identifier | Lowercase author name | "ivmakk" |

**Note**: These are sample values for demonstration. When creating your mod, replace with your actual mod-specific values following the naming rules above.


## Next Steps After Setup:

1. **Replace images**: Update icon.png, poster.png, preview.png, thumb_01.jpg with your mod's artwork
2. **Customize**: Modify Lua files for your specific mod functionality
3. **Update**: Fill in README.md and mod.info with actual content

## Template Structure:
```
ModTemplateIvmakk/
├── .github/                    # Instructions & prompts  
├── .gitignore                  # Basic ignore rules
├── LICENSE                     # MIT license
├── README.md                   # Basic template
├── CHANGELOG.md                # Version tracking
├── workshop_assets/            # Dev assets
└── Contents/                   # Actual mod (uploads to Workshop)
    └── mods/
        └── {MOD_NAME}/
            ├── common/         # Mandatory empty folder
            │   └── media/
            └── 42/             # B42 version folder
                ├── mod.info    # Mod metadata
                └── media/lua/
                    ├── client/ # Client scripts
                    ├── server/ # Server scripts  
                    └── shared/ # Shared scripts + translations
```
