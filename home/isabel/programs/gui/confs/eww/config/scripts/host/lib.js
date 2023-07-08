'@typelibPath@'.split(':').forEach(path => imports.gi.GIRepository.Repository.prepend_search_path(path));

imports.gi.versions.Gtk = '3.0'
imports.gi.versions.Gio = '2.0'
imports.gi.versions.GLib = '2.0'
imports.gi.versions.GObject = '2.0'
imports.gi.versions.UPowerGlib = '1.0'
imports.gi.versions.GnomeBluetooth = '3.0'
imports.gi.versions.NM = '1.0'
imports.gi.versions.GdkPixbuf = '2.0'

'@typelibPath@'.split(':').forEach(path => imports.gi.GIRepository.Repository.prepend_search_path(path));

export const {
  Gtk,
  Gio,
  GLib,
  GObject,
  UPowerGlib,
  GnomeBluetooth,
  NM,
  GdkPixbuf,
} = imports.gi;
