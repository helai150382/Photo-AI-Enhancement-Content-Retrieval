/// 美女拍照小技巧：图文卡片内容。
///
/// 图片使用 text_to_image 生成占位图（landscape_16_9 横版）。
class PhotoTipCard {
  const PhotoTipCard({
    required this.title,
    required this.category,
    required this.summary,
    required this.body,
    required this.imageUrl,
  });

  final String title;

  /// 标签，如「构图」「光线」「角度」。
  final String category;

  final String summary;

  /// 展开后的完整技巧说明（支持 \n 换行）。
  final String body;

  final String imageUrl;
}

/// 按提示词拼装生成式图片 URL（SDXL 风格提示，URL 编码）。
String _pic(String prompt) =>
    'https://trae-api-cn.mchost.guru/api/ide/v1/'
    'text_to_image?prompt=${Uri.encodeComponent(prompt)}'
    '&image_size=landscape_16_9';

/// 内置技巧卡片（非 const，imageUrl 需运行时拼接）。
final List<PhotoTipCard> kPhotoTips = [
  PhotoTipCard(
    title: '三分法构图，人物放对位置',
    category: '构图',
    summary: '把女孩放在画面 1/3 处，比居中更自然耐看。',
    body:
        '1. 打开相机的网格线，将人物放在左侧或右侧的 1/3 分界线上。\n'
        '2. 拍半身时，让眼睛落在上面 1/3 的横线上，画面更有呼吸感。\n'
        '3. 若想突出氛围，把人物放在下方 1/3，上方留出大面积干净天空或背景。\n'
        '4. 避免把人物顶在正中间或紧贴边缘，留白越多越显得高级。',
    imageUrl: _pic(
        '三分法构图拍摄女孩 人物位于画面右侧三分之一处 明亮自然光 浅景深 时尚人像摄影 高清'),
  ),
  PhotoTipCard(
    title: '45° 俯拍，显脸小又灵动',
    category: '角度',
    summary: '手机略高于脸，从上往下 45° 角俯拍最显脸小。',
    body:
        '1. 让女孩低头或微微侧脸，镜头略高于眼睛水平线，即「45° 俯拍」。\n'
        '2. 角度越高越显脸小，但避免过高拍到头顶会显秃。\n'
        '3. 搭配微微抬下巴的动作，能同时拉长颈部线条。\n'
        '4. 抓拍低头浅笑或看向镜头的瞬间，表情更自然。',
    imageUrl: _pic(
        '45度俯拍女孩 低头浅笑 显脸小 校园 明亮自然光 特写 人像摄影 高清'),
  ),
  PhotoTipCard(
    title: '窗边柔光，肤色透亮',
    category: '光线',
    summary: '窗户边的自然散射光，是最好的免费柔光灯。',
    body:
        '1. 站在窗户边，光线从侧面 45° 打向脸部，立体又不刺眼。\n'
        '2. 背对窗户逆光时，可拍出柔和发丝光轮廓（记得提高一点曝光）。\n'
        '3. 正午强光会形成硬影，拉上纱帘让光变柔。\n'
        '4. 让眼睛迎着光的方向看，眼神会格外有光。',
    imageUrl: _pic(
        '女孩站在窗边 柔和自然散射光 皮肤通透 白色纱帘 唯美人像摄影 高清'),
  ),
  PhotoTipCard(
    title: '黄金时刻，自带滤镜',
    category: '光线',
    summary: '日出后 / 日落前一小时，暖光让照片自带滤镜。',
    body:
        '1. 傍晚太阳快落山时（日落前 1 小时）光线最柔和、最金黄。\n'
        '2. 让女孩背对夕阳，构一幅温暖的剪影，很有氛围感。\n'
        '3. 或侧对夕阳，让暖光照亮侧脸，皮肤会非常好看。\n'
        '4. 阴天反而是均匀的天然柔光箱，适合拍清新风格的半身照。',
    imageUrl: _pic(
        '日落黄金时刻 女孩背影与夕阳 暖金色光线 逆光氛围 唯美人像摄影 高清'),
  ),
  PhotoTipCard(
    title: '侧脸 + 微仰，五官更有型',
    category: '姿势',
    summary: '侧脸微仰 15°，五官立体度立刻提升。',
    body:
        '1. 让女孩侧身面对镜头约 45°，再微微抬起下巴。\n'
        '2. 这个角度能让鼻梁、下颌线更清晰，脸型更立体。\n'
        '3. 手可以自然地撩头发、扶帽檐，避免僵硬的「站军姿」。\n'
        '4. 拍几张连拍，从中挑表情最自然的。',
    imageUrl: _pic(
        '女孩侧脸微仰 立体五官 下颌线 撩头发 自然光 时尚人像摄影 高清'),
  ),
  PhotoTipCard(
    title: '不看镜头，更有故事感',
    category: '姿势',
    summary: '看向远方或低头，比直勾勾看镜头更有氛围。',
    body:
        '1. 让女孩看向画面外一侧的远处，眼神有方向感，照片更有故事感。\n'
        '2. 低头整理头发、衣角，或假装在走路，抓拍会比摆拍自然很多。\n'
        '3. 回眸一笑是经典款：先往前走，再自然回头。\n'
        '4. 拍摄时多聊天分散注意力，表情会放松不少。',
    imageUrl: _pic(
        '女孩看向远方 不看镜头 抓拍 自然动作 街道 电影感人像摄影 高清'),
  ),
  PhotoTipCard(
    title: '素净背景，突出主角',
    category: '环境',
    summary: '背景越干净，人物越突出。',
    body:
        '1. 尽量选纯色墙、草地、天空或虚化的街道做背景。\n'
        '2. 避开电线杆、垃圾桶等杂物，或站近些利用虚化把它们「糊掉」。\n'
        '3. 背景颜色尽量和服装形成对比（如浅色衣服配深色墙）。\n'
        '4. 蹲低一点拍摄，用低角度让背景只剩干净的天空。',
    imageUrl: _pic(
        '女孩站在素净简约背景前 浅色墙 干净画面 突出人物 时尚人像摄影 高清'),
  ),
  PhotoTipCard(
    title: '后期三步：曝光、肤色、锐化',
    category: '后期',
    summary: '手机修图三步：提亮、调肤色、微锐化。',
    body:
        '1. 曝光：脸部偏暗就轻微提亮，避免过曝让细节丢失。\n'
        '2. 肤色：色温偏黄时稍减暖、提高一点肤色亮度，白里透红更上镜。\n'
        '3. 对比与锐化：小幅增加对比让照片更「干净」，锐化 20% 以内即可。\n'
        '4. 同一场景拍多张，后期统一调色，朋友圈连发更耐看。',
    imageUrl: _pic(
        '手机后期修图界面 提亮肤色 人像照片编辑 时尚 简洁 高清'),
  ),
];
