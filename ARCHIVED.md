# ARCHIVED: Prysm

**Status**: Archived (March 8, 2025)  
**Reason**: Uses unreleased macOS API

---

## Why Archived

Prysm uses `LanguageModelSession` from Apple's FoundationModels framework, which requires **macOS 26.0** or newer. This version of macOS has not been released yet (current latest is macOS 15.x).

**Build Error**:
```
FoundationModelsError.swift:35:48: error: 'LanguageModelSession' is only 
available in macOS 26.0 or newer
```

---

## What Was Prysm

A native macOS AI chat application using on-device machine learning via Apple's FoundationModels framework.

**Key Features**:
- On-device AI inference (no cloud required)
- SwiftUI interface
- Conversation history
- Tool calling capabilities

---

## To Restore

When macOS 26.0 is released:

1. Update `Prysm.xcodeproj/project.pbxproj` deployment target to 26.0
2. Uncomment/fix `FoundationModelsError.swift` 
3. Update `FoundationModelsErrorHandler` to use actual API
4. Test and deploy

---

## Alternative Approaches

If you want a working macOS AI app now:

1. **Use OpenAI/Anthropic API** - Replace FoundationModels with network calls
2. **Use llama.cpp** - Local inference with open-source models
3. **Use Ollama** - Local LLM runtime with Swift binding

---

## Last Working Commit

See commit history before March 8, 2025 for the full codebase.

---

*Archived by Sisyphus during comprehensive QA sweep*
