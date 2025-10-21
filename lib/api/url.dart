class UserU {
  static const info = '/user';
  static const code = '/code';
  static const login = '/user/login';
  static const loginByEmail = '/user/loginByEmail';
  static const logout = '/user/logout';
  static const sendLoginCode = '/user/sendLoginCode';
  static const registerCode = '/user/sendCode';
  static const register = '/user/registry';
  static const retrievePass = '/user/retrievePassMail';
  static const getCode = '/user/generateCode';
  static const codeBackInitial = '/user/backCodeInitial';
  static const getCodeStatus = '/user/codeStatus';
}

class MineU {
  static const favoriteIds = '/mine/favoriteIds';
  static const favorite = '/mine/favorite';
  static const recentPlay = '/mine/recentPlay';
  static const recentPlayMul = '/mine/recentPlayMul';
}

class MusicU {
  static const musList = '/music/musList';
  static const musListPrivate = '/music/musListPrivate';
  static const musListImgUrl = '/music/musListImgUrl';
  static const musListMusIds = '/music/musListMusIds';
  static const setMusOnList = '/music/setMusOnList';
}

class HomeU {
  static const recentUp = '/home/upNewMusic';
  static const everyOneMus = '/home/everyOneMusic';
  static const adMusListUp = '/home/adMusicList';
  static const exqMusListUp = '/home/exqMusicList';
  static const categoryMusics = '/home/categoryMusics';
  static const banner = '/home/banner';
  static const poem = '/home/poem';
}

// 路径含 o 为后台缓存接口
class ExploreU {
  static const musdetail = '/explore/musDetail';
  static const musdetailO = '/explore/musDetailO';
  static const search = '/explore/search';
  static const searchHint = '/explore/searchHint';
  static const musdetailLS = '/explore/musDetailLS';
  static const musListdetail = '/explore/musListDetail';
  static const lycdetail = '/explore/lyricDetail';
  static const lycdetailO = '/explore/lyricDetailO';
  static const vidDetail = '/explore/videoDetail';
  static const singerDetail = '/explore/singerDetail';
  static const albumList = '/explore/albumList';
  static const albumDetail = '/explore/albumDetail';
}

class AssistU {
  static const musTypes = '/assist/musTypes';
  static const singerTypes = '/assist/singerTypes';
}

class UpgradeU {
  static const check = '/update/check';
  static const allDownload = '/update/allDownload';
}

class UploadU {
  static const mediaImg = '/upload/mediaImg';
}

class SettingU {
  static const announce = '/setting/announce/last';
}
