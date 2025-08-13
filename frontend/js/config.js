window.LIVEE_CONFIG = {
  BASE_PATH: '/alpa',
  API_BASE: 'https://main-server-ekgr.onrender.com/api/v1',

  // ⬇️ 서명 업로드에 필요한 건 업로드 엔드포인트뿐
  CLOUDINARY: {
    uploadApi: 'https://api.cloudinary.com/v1_1/dis1og9uq/image/upload'
  },

  thumb: {
    square: 'c_fill,g_auto,w_320,h_320,f_auto,q_auto',
    card169: 'c_fill,g_auto,w_640,h_360,f_auto,q_auto'
  }
};