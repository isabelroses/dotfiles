import QtQuick
import Quickshell
import Quickshell.Services.Polkit
import qs.data
import qs.components

Scope {
  PolkitAgent {
    id: agent
  }

  LazyLoader {
    active: agent.isActive && agent.flow !== null

    Modal {
      id: win
      namespace: "polkit"
      readonly property AuthFlow flow: agent.flow
      property bool submitting: false
      onDismissed: flow?.cancelAuthenticationRequest()

      PasswordPrompt {
        id: prompt
        title: "Authentication required"
        subtitle: win.flow?.message ?? ""
        detail: win.flow?.actionId ?? ""
        placeholder: (win.flow?.inputPrompt ?? "").replace(/:\s*$/, "") || "Password"
        revealable: !(win.flow?.responseVisible ?? false)
        message: win.flow?.supplementaryMessage ?? ""
        error: win.flow?.supplementaryIsError ?? false
        busy: win.submitting || !(win.flow?.isResponseRequired ?? false)
        confirmText: "Authenticate"
        onCancelled: win.dismissed()
        onSubmitted: (password) => {
          win.submitting = true;
          win.flow.submit(password);
        }
      }

      Connections {
        target: win.flow
        function onIsResponseRequiredChanged() {
          if (!win.flow.isResponseRequired) return;
          win.submitting = false;
          prompt.takeFocus();
        }
        function onAuthenticationFailed() {
          win.submitting = false;
          prompt.shake();
        }
      }
    }
  }
}
