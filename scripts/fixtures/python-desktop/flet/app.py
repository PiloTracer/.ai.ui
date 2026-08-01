"""FLET desktop skeleton proof — py_compile/stdlib only (flet not required to compile)."""
import flet as ft


def main(page: ft.Page):
    page.title = "Demo"
    page.add(ft.Text("Desktop scaffold proof"))


if __name__ == "__main__":
    ft.app(target=main)
