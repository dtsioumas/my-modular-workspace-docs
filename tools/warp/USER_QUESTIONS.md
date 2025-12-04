# Warp Terminal - User Questions & Preferences

Before proceeding with Warp installation, I need your input on these key decisions.

---

## Critical Questions (Must Answer)

### 1. Terminal Strategy: Replace or Parallel?

**Question**: Do you want Warp to **replace** Kitty completely, or run **alongside** it?

**Options**:

**A) Complete Replacement**
- Pros:
  - Single terminal to maintain
  - Simpler configuration
  - Clean migration
- Cons:
  - All workflows must work in Warp
  - No fallback if issues arise initially
  - Muscle memory adjustment

**B) Parallel Use**
- Pros:
  - Keep Kitty for reliable workflows
  - Gradually adopt Warp
  - Easy fallback
  - Can use best tool for each task
- Cons:
  - Maintain two terminal configs
  - More complex setup
  - Context switching between terminals

**C) Trial Period Then Decide**
- Try Warp for 1-2 weeks
- Keep Kitty available
- Decide after real usage
- **Recommended for safety**

**Your answer**: _____________

---

### 2. Existing Warp Configuration

**Question**: Do you have an existing Warp configuration from another machine?

**Options**:
- **A)** Yes, I have Warp configs to import (please provide location)
- **B)** No, start fresh with recommended defaults
- **C)** I want to base it on my Kitty configuration

**Your answer**: _____________

**If A**: Config location: _____________

---

### 3. GPU Acceleration Preference

**Question**: How should Warp use your NVIDIA GTX 960?

**Context**: GPU acceleration improves scrolling and rendering but uses more power.

**Options**:
- **A)** Always use GPU (maximum performance)
- **B)** Use GPU only for Warp, let system decide
- **C)** Disable GPU for Warp (power saving)

**Your answer**: _____________

---

## Important Questions (Recommended to Answer)

### 4. Warp Account

**Question**: Do you already have a Warp account?

**Options**:
- **A)** Yes, I have an account (ready to sign in)
- **B)** No, I'll create one during setup
- **C)** I want to delay account creation (note: limits some features)

**Your answer**: _____________

---

### 5. Theming Preference

**Question**: What theme should Warp use?

**Current Kitty theme**: Dracula (based on config)

**Options**:
- **A)** Dracula (match Kitty)
- **B)** Catppuccin Mocha (your previous Kitty theme)
- **C)** Warp's default theme
- **D)** I'll explore and choose later

**Your answer**: _____________

---

### 6. Keybinding Strategy

**Question**: How should keybindings be configured?

**Options**:
- **A)** Mirror Kitty keybindings (minimal learning curve)
- **B)** Use Warp defaults (learn new system)
- **C)** Hybrid (Warp defaults + critical Kitty shortcuts)

**Your answer**: _____________

**If A or C**, which Kitty shortcuts are most critical?
- Examples from your Kitty config:
  - `Ctrl+Alt+H/V` - split window
  - `Alt+Left/Right` - switch tabs
  - `F12` - dropdown panel
  - `Ctrl+Shift+F9` - theme selector

**Critical shortcuts**: _____________

---

### 7. AI Features

**Question**: How interested are you in Warp's AI features?

**Warp AI capabilities**:
- Natural language command generation
- Code writing assistance
- Error explanation
- Command suggestions

**Options**:
- **A)** Very interested - configure AI from day 1
- **B)** Moderately interested - explore after basic setup
- **C)** Not interested - minimal AI configuration
- **D)** Need to understand more before deciding

**Your answer**: _____________

---

### 8. Launch Configurations

**Question**: Should we create launch configurations for your common workflows?

**Context**: Launch configs are like tmux/zellij sessions - pre-configured window/tab/pane layouts.

**Your typical workflows** (based on project structure):
1. `my-modular-workspace` development (home-manager, docs, ansible)
2. `shoshin-nixos` configuration work
3. General purpose / scratch workspace

**Options**:
- **A)** Yes, create launch configs for all 3 workflows
- **B)** Yes, but only for #1 (most common)
- **C)** No, I'll create them manually as needed
- **D)** Not sure what launch configs are yet

**Your answer**: _____________

---

## Optional Questions (Nice to Have)

### 9. Font Preference

**Current Kitty font**: JetBrains Mono Nerd Font (size 12)

**Question**: Continue with same font in Warp?

**Your answer**: _____________ (Yes/No/Different font)

---

### 10. Window Management

**Current Kitty setup**:
- Splits: Ctrl+Alt+H (horizontal), Ctrl+Alt+V (vertical)
- Tab bar on top, powerline style
- Background opacity: 0.15 (very transparent) with blur

**Question**: Keep similar window management in Warp?

**Your answer**: _____________ (Yes/No/Adjust)

---

### 11. Testing Approach

**Question**: How do you want to test Warp before committing?

**Options**:
- **A)** Install and test immediately with real work
- **B)** Install and test with non-critical tasks first
- **C)** Install but keep as secondary until confident
- **D)** Install in a VM first (extra cautious)

**Your answer**: _____________

---

### 12. Performance Monitoring

**Question**: Should we set up performance monitoring to compare Warp vs Kitty?

**Would track**:
- Startup time
- Memory usage
- GPU utilization
- Responsiveness

**Your answer**: _____________ (Yes/No/Maybe later)

---

## Summary of Recommendations

Based on your context (ADHD, preference for working tools, limited free time):

**My recommendations**:
1. **Strategy**: Parallel use (B) or Trial Period (C) - safest approach
2. **Existing Config**: Start fresh (B) with proven patterns
3. **GPU**: Always use GPU (A) - you have the hardware
4. **Account**: Create during setup (B) - enables full features
5. **Theme**: Dracula (A) - matches current workflow
6. **Keybindings**: Hybrid (C) - keep critical Kitty shortcuts
7. **AI**: Explore after setup (B) - avoid overwhelming initial config
8. **Launch Configs**: Create for main workflow only (B) - start simple

**Rationale**: This balances new features with stability and minimizes disruption to your productive workflow.

---

## Action Items

1. **Answer** the critical questions (#1-3) before we proceed
2. **Consider** the important questions (#4-8) for better setup
3. **Optionally answer** remaining questions (#9-12) for refinement
4. **Review** the [IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md) with your answers in mind

---

**Notes**:
- You can answer "I don't know yet" or "decide later" for non-critical questions
- We can always adjust configuration after initial setup
- No need to answer everything at once - we can iterate

---

**Ready to proceed?** Once you've answered the critical questions, we can start Phase 2 (Installation).
