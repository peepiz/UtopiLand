shader_type spatial;
render_mode blend_mix, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// Масштаб клеток (чем больше, тем мельче)
uniform float scale = 4.0; 

// Утилита для шахматного узора (в мировом пространстве)
float checker(vec2 uv) {
	float check = floor(uv.x) + floor(uv.y);
	return mod(check, 2.0);
}

// Грязные пятна
float dirt_noise(vec2 uv) {
	vec2 st = uv * 3.14159;
	float f = sin(st.x + sin(st.y));
	f += cos(st.y + cos(st.x));
	return smoothstep(-0.3, 0.7, sin(f * 2.5));
}

void fragment() {
	// 1. Получаем истинные мировые координаты пикселя
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// 2. Считаем шахматный узор для ТРЁХ плоскостей (Top, Side, Front)
	float check_xz = checker(world_pos.xz * scale); // Проекция сверху (YZ)
	float check_xy = checker(world_pos.xy * scale); // Проекция спереди (XY)
	float check_zy = checker(world_pos.zy * scale); // Проекция сбоку (ZY)
	
	// 3. Вычисляем "вес" для смешивания на основе НАКЛОНА поверхности (NORMAL)
	// Берем абсолютное значение нормали и делаем её резкой (power), чтобы не было "мыла" на краях
	vec3 triplanar_blend = pow(abs(NORMAL), vec3(8.0));
	
	// Нормализуем веса, чтобы в сумме было 1.0
	triplanar_blend /= (triplanar_blend.x + triplanar_blend.y + triplanar_blend.z);
	
	// 4. СМЕШИВАЕМ всё в одну финальную шахматную доску!
	// Это самая важная часть. Теперь глитч будет огибать любой наклон.
	float final_check = (check_xz * triplanar_blend.y) + (check_xy * triplanar_blend.z) + (check_zy * triplanar_blend.x);
	
	// 5. То же самое делаем для грязи
	float dirt_xz = dirt_noise(world_pos.xz * 0.2);
	float dirt_xy = dirt_noise(world_pos.xy * 0.2);
	float dirt_zy = dirt_noise(world_pos.zy * 0.2);
	float final_dirt = (dirt_xz * triplanar_blend.y) + (dirt_xy * triplanar_blend.z) + (dirt_zy * triplanar_blend.x);
	
	// 6. Задаем цвета (Розовый, Черный)
	vec3 color_check_black = vec3(0.0); // Черный
	vec3 color_check_pink = vec3(1.0, 0.0, 1.0); // Ярко-розовый
	
	// Финальный цвет шахмат
	vec3 final_color = mix(color_check_black, color_check_pink, step(0.5, final_check));
	
	// 7. Накладываем грязные пятна
	final_color = mix(final_color, vec3(1.0), final_dirt * final_check * 0.7);
	
	ALBEDO = final_color;
}