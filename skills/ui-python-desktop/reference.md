# ui-python-desktop — primitive map

Companion to `skill.md`. Maps SPEC primitives (foundation doc 03 / screen SPEC §8) to FLET controls and Qt widgets. Style via tokens only; no default chrome.

| Primitive | FLET control | Qt widget (PySide6/PyQt6) |
|-----------|--------------|---------------------------|
| Button (primary/secondary) | `ft.FilledButton` / `ft.OutlinedButton` | `QPushButton` (+ QSS from tokens) |
| Text input | `ft.TextField` | `QLineEdit` (single) / `QTextEdit` (multi) |
| Select / dropdown | `ft.Dropdown` | `QComboBox` |
| Checkbox / switch | `ft.Checkbox` / `ft.Switch` | `QCheckBox` |
| Table / data grid | `ft.DataTable` | `QTableWidget` |
| List | `ft.ListView` / `ft.Column` | `QListWidget` |
| Navigation rail / sidebar | `ft.NavigationRail` | `QListWidget` (left) or `QToolBar` |
| Tabs | `ft.Tabs` | `QTabWidget` |
| Dialog / modal | `ft.AlertDialog` | `QDialog` |
| Toast / snackbar | `ft.SnackBar` | `QMessageBox` / status bar |
| Tooltip | `ft.Tooltip` | `setToolTip()` |
| Progress | `ft.ProgressBar` / `ft.ProgressRing` | `QProgressBar` |
| Chart (analytical) | `ft.matplotlib.Chart` (or flet-charts) | `QtCharts` / matplotlib canvas |
| Layout container | `ft.Row` / `ft.Column` / `ft.Container` | `QHBoxLayout` / `QVBoxLayout` / `QWidget` |
| Theme binding | `ft.Theme(color_scheme_seed=…)` / `page.theme` from tokens | `QApplication.setPalette` / QSS from tokens |

**Token binding:** colors/type/spacing come from DTCG `tokens.json` (Phase 2) emitted as `tokens.py` constants or inline theme objects — components reference token **names**, never raw hex (token-lint enforces on `.py`).

**Stack dialect note:** PySide6 ↔ PyQt6 are API-compatible for the map above — only the import line differs (`from PySide6.QtWidgets import …` vs `from PyQt6.QtWidgets import …`).
