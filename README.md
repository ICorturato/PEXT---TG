# PEXT Front-end Prototype

Static Flutter user-interface prototype for the PEXT polymer coextrusion application.

This workspace includes a project-local Flutter SDK in `.flutter-sdk` and complete platform projects for Android, iOS, web, Windows, Linux, and macOS.

## Run in VS Code

1. Open the `PEXT - SISTEMA` folder in VS Code.
2. Install the Dart and Flutter extensions if prompted.
3. Select `PEXT (Windows)` or `PEXT (Edge)` in **Run and Debug**, then press `F5`.

The VS Code workspace settings already point the Dart extension at the local SDK. From the integrated terminal, the equivalent commands are:

```powershell
.\.flutter-sdk\bin\flutter.bat pub get
.\.flutter-sdk\bin\flutter.bat run -d windows
```

The current implementation is intentionally front-end only. It includes visual navigation between the login, user/admin home, favourites, assistant chat and support escalation, glossary, resins, training and assessment, troubleshooting and verification flow, packaging management, dashboard/audit activity, and profile/security pages.

## Included front-end flows

- User and administrator profile selection from the login screen.
- Role-aware quick access and navigation.
- AI assistant conversation and supervisor-support request state.
- Searchable glossary, resin catalogue, resin detail tabs, and resin registration form.
- Training status list, module view, administrator training editor, assessment, and result state.
- Troubleshooting list, administrator problem/verification setup, and a three-step user diagnostic wizard.
- Packaging list and visual registration entry point.
- Favourites, administrator dashboard activity, and profile/security tabs.

No Firebase, authentication, database, file upload, AI service, or persistence is connected yet.
