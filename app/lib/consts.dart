// Servers ports
const APICompositionPort = '1101';
const APINeuralNetworkPort = '8000'; // temp

// Servers hosts
const APICompositionHost = '192.168.1.78';

// Request URLs
const styleImageURL =  'http://$APICompositionHost:$APINeuralNetworkPort/api/style_image';
const getImageURL = 'http://$APICompositionHost:$APICompositionPort/api/get_image';
const saveImageURL = 'http://$APICompositionHost:$APICompositionPort/api/save_image';

// Requests methods
const post = 'post';

// HTTP constants
const contentType = 'Content-Type';
const applicationJSON = 'application/json';
const imagePNG = "image/png";