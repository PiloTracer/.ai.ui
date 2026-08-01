"""PySide6 desktop skeleton proof — py_compile/stdlib only (PySide6 not required to compile)."""
from PySide6.QtWidgets import QApplication, QLabel, QWidget


def main():
    app = QApplication([])
    root = QWidget()
    label = QLabel("Desktop scaffold proof")
    label.setParent(root)
    root.show()
    app.exec()


if __name__ == "__main__":
    main()
