"""
Script para generar los iconos de Control Financiero
Ejecutar con: python generate_icon.py
Requiere: pip install pillow
"""

from PIL import Image, ImageDraw, ImageFont
import os
import math

def create_app_icon():
    # Tamaño del icono
    size = 1024
    
    # Crear imagen con fondo degradado estilo Binance
    img = Image.new('RGB', (size, size))
    draw = ImageDraw.Draw(img)
    
    # Degradado dorado/amarillo oscuro a negro (estilo Binance)
    for y in range(size):
        ratio = y / size
        # Gradiente oscuro profesional
        r = int(25 + (15 - 25) * ratio)
        g = int(25 + (15 - 25) * ratio)
        b = int(28 + (18 - 28) * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    circle_center = (size // 2, size // 2)
    
    # Color dorado profesional (estilo Binance)
    gold_color = (243, 186, 47)  # Dorado Binance
    
    # Diseño geométrico: diamante/rombo estilizado con líneas
    diamond_size = 280
    
    # Puntos del diamante principal
    top = (circle_center[0], circle_center[1] - diamond_size)
    right = (circle_center[0] + diamond_size, circle_center[1])
    bottom = (circle_center[0], circle_center[1] + diamond_size)
    left = (circle_center[0] - diamond_size, circle_center[1])
    
    # Dibujar rombo/diamante principal con relleno
    diamond_points = [top, right, bottom, left]
    draw.polygon(diamond_points, fill=gold_color)
    
    # Diamante interno más pequeño (efecto de profundidad)
    inner_size = 160
    top_inner = (circle_center[0], circle_center[1] - inner_size)
    right_inner = (circle_center[0] + inner_size, circle_center[1])
    bottom_inner = (circle_center[0], circle_center[1] + inner_size)
    left_inner = (circle_center[0] - inner_size, circle_center[1])
    
    inner_diamond = [top_inner, right_inner, bottom_inner, left_inner]
    draw.polygon(inner_diamond, fill=(30, 30, 35))
    
    # Líneas diagonales internas (detalles geométricos)
    line_width = 18
    
    # Líneas desde el centro hacia las esquinas del diamante interno
    for point in inner_diamond:
        draw.line([circle_center, point], fill=gold_color, width=line_width)
    
    # Cuadrado central pequeño
    square_size = 45
    square_coords = [
        circle_center[0] - square_size, circle_center[1] - square_size,
        circle_center[0] + square_size, circle_center[1] + square_size
    ]
    draw.rectangle(square_coords, fill=gold_color)
    
    # Puntos en las esquinas del diamante exterior (detalles)
    dot_size = 25
    for point in diamond_points:
        draw.ellipse(
            [point[0] - dot_size, point[1] - dot_size,
             point[0] + dot_size, point[1] + dot_size],
            fill=gold_color
        )
    
    # Pequeñas líneas decorativas en las esquinas
    accent_length = 60
    accent_width = 12
    
    # Superior
    draw.line(
        [(top[0] - accent_length, top[1] - 40), (top[0] + accent_length, top[1] - 40)],
        fill=gold_color, width=accent_width
    )
    # Inferior
    draw.line(
        [(bottom[0] - accent_length, bottom[1] + 40), (bottom[0] + accent_length, bottom[1] + 40)],
        fill=gold_color, width=accent_width
    )
    # Izquierda
    draw.line(
        [(left[0] - 40, left[1] - accent_length), (left[0] - 40, left[1] + accent_length)],
        fill=gold_color, width=accent_width
    )
    # Derecha
    draw.line(
        [(right[0] + 40, right[1] - accent_length), (right[0] + 40, right[1] + accent_length)],
        fill=gold_color, width=accent_width
    )
    
    return img

def create_foreground_icon():
    # Icono para adaptive icon (sin fondo) - estilo Binance
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    circle_center = (size // 2, size // 2)
    gold_color = (243, 186, 47, 255)
    
    # Diseño geométrico: diamante/rombo
    diamond_size = 280
    
    top = (circle_center[0], circle_center[1] - diamond_size)
    right = (circle_center[0] + diamond_size, circle_center[1])
    bottom = (circle_center[0], circle_center[1] + diamond_size)
    left = (circle_center[0] - diamond_size, circle_center[1])
    
    diamond_points = [top, right, bottom, left]
    draw.polygon(diamond_points, fill=gold_color)
    
    # Diamante interno
    inner_size = 160
    top_inner = (circle_center[0], circle_center[1] - inner_size)
    right_inner = (circle_center[0] + inner_size, circle_center[1])
    bottom_inner = (circle_center[0], circle_center[1] + inner_size)
    left_inner = (circle_center[0] - inner_size, circle_center[1])
    
    inner_diamond = [top_inner, right_inner, bottom_inner, left_inner]
    draw.polygon(inner_diamond, fill=(30, 30, 35, 255))
    
    # Líneas desde el centro
    line_width = 18
    for point in inner_diamond:
        draw.line([circle_center, point], fill=gold_color, width=line_width)
    
    # Cuadrado central
    square_size = 45
    square_coords = [
        circle_center[0] - square_size, circle_center[1] - square_size,
        circle_center[0] + square_size, circle_center[1] + square_size
    ]
    draw.rectangle(square_coords, fill=gold_color)
    
    # Puntos en las esquinas
    dot_size = 25
    for point in diamond_points:
        draw.ellipse(
            [point[0] - dot_size, point[1] - dot_size,
             point[0] + dot_size, point[1] + dot_size],
            fill=gold_color
        )
    
    # Líneas decorativas
    accent_length = 60
    accent_width = 12
    
    draw.line(
        [(top[0] - accent_length, top[1] - 40), (top[0] + accent_length, top[1] - 40)],
        fill=gold_color, width=accent_width
    )
    draw.line(
        [(bottom[0] - accent_length, bottom[1] + 40), (bottom[0] + accent_length, bottom[1] + 40)],
        fill=gold_color, width=accent_width
    )
    draw.line(
        [(left[0] - 40, left[1] - accent_length), (left[0] - 40, left[1] + accent_length)],
        fill=gold_color, width=accent_width
    )
    draw.line(
        [(right[0] + 40, right[1] - accent_length), (right[0] + 40, right[1] + accent_length)],
        fill=gold_color, width=accent_width
    )
    
    return img

# Crear directorio si no existe
os.makedirs('assets/icon', exist_ok=True)

# Generar iconos
print("Generando icono principal...")
icon = create_app_icon()
icon.save('assets/icon/app_icon.png')
print("✓ Icono principal guardado: assets/icon/app_icon.png")

print("Generando icono foreground para Android...")
foreground = create_foreground_icon()
foreground.save('assets/icon/app_icon_foreground.png')
print("✓ Icono foreground guardado: assets/icon/app_icon_foreground.png")

print("\n✅ Iconos generados exitosamente!")
print("\nPara aplicar los iconos, ejecuta:")
print("  flutter pub get")
print("  flutter pub run flutter_launcher_icons")
