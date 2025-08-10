// 중앙 설정: 경로/백엔드/Cloudinary
window.LIVEE_CONFIG = {
  BASE_PATH: '/alpa',
  API_BASE: 'https://main-server-ekgr.onrender.com/api/v1',
  CLOUDINARY: {
    cloudName: 'dis1og9uq',
    uploadPreset: 'livee_unsigned',
    uploadApi: 'https://api.cloudinary.com/v1_1/dis1og9uq/image/upload'
  },
  thumb: {
    square: 'c_fill,g_auto,w_320,h_320,f_auto,q_auto',
    card169: 'c_fill,g_auto,w_640,h_360,f_auto,q_auto'
  }
};