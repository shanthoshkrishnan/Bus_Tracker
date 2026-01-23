from PIL import Image
import os

img = Image.open('Gemini_Generated_Image_gqwa0bgqwa0bgqwa.png')
sizes = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}

for density, size in sizes.items():
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    output_path = f'android/app/src/main/res/mipmap-{density}/ic_launcher.png'
    resized.save(output_path)
    print(f'✓ Created {density}: {size}x{size}')

print('\n✓ Android icons created successfully!')
