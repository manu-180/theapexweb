Remove-Item -Recurse -Force docs
flutter build web
mkdir docs    
cp -r build/web/* docs/
git add .
git commit -m "vercel" 
git push

seleccionar el icono :
""
dart run flutter_launcher_icons 
""
