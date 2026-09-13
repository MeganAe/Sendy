"""Sendy icons, derived from our original vector mark, not from upstream artwork.
Run from the repository root: pip install cairosvg pillow; python support/branding/generate_icons.py
"""
from pathlib import Path
from io import BytesIO
import json
import cairosvg
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
P = 'M13 0H48Q51 0 54 3L62 11V28Q62 34 56 34H46C26 34 26 64 46 64C54 64 54 73 46 73H13Q0 73 0 60V13Q0 0 13 0Z'

def svg(color='#F4F1E9', background=True, adaptive=False):
    bg = '<rect width="256" height="256" rx="55" fill="#19345C"/>' if background else ''
    scale = 1.12 if not adaptive else 1.0
    x, y = (256-100*scale)/2, (256-116*scale)/2
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256">{bg}<g fill="{color}" transform="translate({x},{y}) scale({scale})"><path d="{P}"/><path d="{P}" transform="translate(100,116) rotate(180)"/></g></svg>'

def render(size, color='#F4F1E9', background=True, adaptive=False):
    return Image.open(BytesIO(cairosvg.svg2png(bytestring=svg(color,background,adaptive).encode(),output_width=size,output_height=size))).convert('RGBA')

def save(image, path):
    path.parent.mkdir(parents=True,exist_ok=True)
    image.save(path)

(ROOT/'support/branding/sendy-icon.svg').write_text(svg())
(ROOT/'support/branding/sendy-mark.svg').write_text(svg('#19345C',False))
for p in (ROOT/'app/assets/img').glob('logo*.png'):
    size=Image.open(p).width
    mono = '-black' in p.stem or '-white' in p.stem
    save(render(size, '#FFFFFF' if '-white' in p.stem else '#19345C' if mono else '#F4F1E9', not mono),p)
for p in [ROOT/'app/assets/img/logo.ico', ROOT/'app/assets/packaging/logo.ico', ROOT/'app/windows/runner/resources/app_icon.ico']:
    render(256).save(p,format='ICO',sizes=[(n,n) for n in [16,24,32,48,64,128,256]])
for p in (ROOT/'app/android/app/src/main/res').glob('mipmap-*/*.png'):
    size=Image.open(p).width
    foreground='foreground' in p.stem or 'monochrome' in p.stem
    save(render(size, background=not foreground, adaptive=foreground),p)
for platform in ['macos','ios']:
    for p in (ROOT/f'app/{platform}/Runner/Assets.xcassets').rglob('*.png'):
        if 'AppIcon' not in str(p) and 'StatusBarItemIcon' not in str(p): continue
        size=Image.open(p).width
        im=render(size, '#000000' if 'StatusBar' in str(p) else '#F4F1E9', 'StatusBar' not in str(p))
        if platform=='ios':
            bg=Image.new('RGB',im.size,'#19345C');bg.paste(im,mask=im.getchannel('A'));im=bg
        if 'WithSuccess' in str(p) or 'WithError' in str(p):
            d=ImageDraw.Draw(im);cx=cy=size*.78;r=size*.19
            d.ellipse((cx-r,cy-r,cx+r,cy+r),fill='#00856B' if 'WithSuccess' in str(p) else '#C74646',outline='white',width=max(1,size//100))
            if 'WithSuccess' in str(p): pts=[(cx-r*.55,cy),(cx-r*.1,cy+r*.38),(cx+r*.55,cy-r*.4)]
            else: pts=[(cx-r*.4,cy-r*.4),(cx+r*.4,cy+r*.4)]
            d.line(pts,fill='white',width=max(2,size//50))
            if 'WithError' in str(p):d.line([(cx-r*.4,cy+r*.4),(cx+r*.4,cy-r*.4)],fill='white',width=max(2,size//50))
        save(im,p)
render(1024).save(ROOT/'app/macos/ShareExtension/icon.icns',format='ICNS')
for p in [ROOT/'app/web/favicon.png',*(ROOT/'app/web/icons').glob('*.png')]:
    save(render(Image.open(p).width),p)
banner=Image.new('RGB',(640,360),'#19345C')
mark=render(150,background=False);banner.paste(mark,(65,105),mark)
d=ImageDraw.Draw(banner)
try:
    font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',74)
except OSError:
    font=ImageFont.load_default(size=74)
d.text((235,131),'sendy',fill='#F4F1E9',font=font)
save(banner.resize((320,180),Image.Resampling.LANCZOS),ROOT/'app/android/app/src/main/res/drawable/banner.png')
# Android vector fallback used by tooling and legacy resource references.
vector=f'''<!-- Sendy original vector mark -->
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
<group android:translateX="33" android:translateY="29.64" android:scaleX="0.42" android:scaleY="0.42">
<path android:fillColor="#F4F1E9" android:pathData="{P}"/>
<group android:translateX="100" android:translateY="116" android:rotation="180"><path android:fillColor="#F4F1E9" android:pathData="{P}"/></group>
</group></vector>'''
(ROOT/'app/android/app/src/main/res/drawable/ic_launcher_foreground.xml').write_text(vector)
print('Sendy icons regenerated for Android, Windows, macOS, Linux assets, iOS and web.')
