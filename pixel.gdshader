shader_type canvas_item;

// Ссылка на то, что происходит на экране под этим прямоугольником
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// Размер "пикселей". Чем меньше цифра, тем крупнее пиксели!
uniform int pixel_size = 5; 

void fragment() {
    // Получаем координаты экрана
    vec2 uv = SCREEN_UV;
    
    // Вычисляем размер пиксельной сетки на основе текущего разрешения
    vec2 screen_size = vec2(textureSize(screen_texture, 0));
    vec2 size_in_pixels = screen_size / float(pixel_size);
    
    // Округляем координаты, чтобы создать эффект мозаики/пикселей
    uv = floor(uv * size_in_pixels) / size_in_pixels;
    
    // Выводим пикселизированную картинку
    COLOR = texture(screen_texture, uv);
}