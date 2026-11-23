import QtQuick
import Quickshell
import qs.data
import qs.services

// Copies the profile picture into AccountsService, so the account picture is
// available system-wide instead of only in this user's config.
Scope {
  readonly property string picture: Settings.general.profile_picture

  onPictureChanged: if (picture !== "") System.setAccountIcon(picture)
  Component.onCompleted: if (picture !== "") System.setAccountIcon(picture)
}
