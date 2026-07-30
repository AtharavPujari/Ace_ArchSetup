pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import qs.services

QtObject {
    id: root

    readonly property bool isDark: !Colours.light

    // Helper functions to resolve raw colors from Colours without circular bindings
    function getRawColor(name: string, isPreview: bool): color {
        const colours = isPreview ? Colours.rawPreviewColours : Colours.rawCurrentColours;
        const hex = colours[name];
        return hex ? `#${hex}` : defaultMaterialFallback(name, isPreview);
    }

    function getSystemMappedColor(tokenName: string, isPreview: bool): color {
        const mapping = {
            "base": "background",
            "surface": "surface",
            "surfaceElevated": "surfaceBright",
            "surfaceCard": "surfaceVariant",
            "outline": "outline",
            "textPrimary": "onSurface",
            "textSecondary": "onSurfaceVariant",
            "textDisabled": "subtext0",
            "shadow": "shadow",
            "primary": "primary",
            "onPrimary": "onPrimary",
            "primaryContainer": "primaryContainer",
            "onPrimaryContainer": "onPrimaryContainer",
            "secondary": "secondary",
            "onSecondary": "onSecondary",
            "secondaryContainer": "secondaryContainer",
            "onSecondaryContainer": "onSecondaryContainer",
            "tertiary": "tertiary",
            "onTertiary": "onTertiary",
            "tertiaryContainer": "tertiaryContainer",
            "onTertiaryContainer": "onTertiaryContainer"
        };
        const rawKey = mapping[tokenName] || tokenName;
        return getRawColor(rawKey, isPreview);
    }

    function defaultMaterialFallback(name: string, isPreview: bool): color {
        const lightDefaults = {
            "background": "#FEF7FF", "surface": "#FEF7FF", "surfaceBright": "#FEF7FF",
            "outline": "#79747E", "onSurface": "#1D1B20", "onSurfaceVariant": "#49454F",
            "subtext0": "#8D817B", "shadow": "#000000"
        };
        const darkDefaults = {
            "background": "#141218", "surface": "#141218", "surfaceBright": "#141218",
            "outline": "#938F99", "onSurface": "#E6E1E9", "onSurfaceVariant": "#CAC4D0",
            "subtext0": "#8D817B", "shadow": "#000000"
        };
        const isLight = Colours.showPreview ? Colours.previewLight : Colours.currentLight;
        const defaults = isLight ? lightDefaults : darkDefaults;
        return defaults[name] || "transparent";
    }

    // Semantic tokens resolving to Obsidian palette in dark mode, and system colors in light mode
    readonly property color base: isDark ? "#090909" : getSystemMappedColor("base", Colours.showPreview)
    readonly property color surface: isDark ? "#111111" : getSystemMappedColor("surface", Colours.showPreview)
    readonly property color surfaceElevated: isDark ? "#171717" : getSystemMappedColor("surfaceElevated", Colours.showPreview)
    readonly property color surfaceCard: isDark ? "#202020" : getSystemMappedColor("surfaceCard", Colours.showPreview)
    readonly property color outline: isDark ? "#2A2A2A" : getSystemMappedColor("outline", Colours.showPreview)
    readonly property color textPrimary: isDark ? "#F5F5F5" : getSystemMappedColor("textPrimary", Colours.showPreview)
    readonly property color textSecondary: isDark ? "#B5B5B5" : getSystemMappedColor("textSecondary", Colours.showPreview)
    readonly property color textDisabled: isDark ? "#6F6F6F" : getSystemMappedColor("textDisabled", Colours.showPreview)
    readonly property color shadow: isDark ? "rgba(0,0,0,0.3)" : getSystemMappedColor("shadow", Colours.showPreview)

    // Dynamic monochrome accents in dark mode, and system accents in light mode
    readonly property color primary: isDark ? "#F5F5F5" : getSystemMappedColor("primary", Colours.showPreview)
    readonly property color onPrimary: isDark ? "#090909" : getSystemMappedColor("onPrimary", Colours.showPreview)
    readonly property color primaryContainer: isDark ? "#202020" : getSystemMappedColor("primaryContainer", Colours.showPreview)
    readonly property color onPrimaryContainer: isDark ? "#F5F5F5" : getSystemMappedColor("onPrimaryContainer", Colours.showPreview)

    readonly property color secondary: isDark ? "#B5B5B5" : getSystemMappedColor("secondary", Colours.showPreview)
    readonly property color onSecondary: isDark ? "#111111" : getSystemMappedColor("onSecondary", Colours.showPreview)
    readonly property color secondaryContainer: isDark ? "#171717" : getSystemMappedColor("secondaryContainer", Colours.showPreview)
    readonly property color onSecondaryContainer: isDark ? "#F5F5F5" : getSystemMappedColor("onSecondaryContainer", Colours.showPreview)

    readonly property color tertiary: isDark ? "#6F6F6F" : getSystemMappedColor("tertiary", Colours.showPreview)
    readonly property color onTertiary: isDark ? "#111111" : getSystemMappedColor("onTertiary", Colours.showPreview)
    readonly property color tertiaryContainer: isDark ? "#171717" : getSystemMappedColor("tertiaryContainer", Colours.showPreview)
    readonly property color onTertiaryContainer: isDark ? "#B5B5B5" : getSystemMappedColor("onTertiaryContainer", Colours.showPreview)
}
