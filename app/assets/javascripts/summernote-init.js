$(document).on('ready', function() {
  function sendFile(file, toSummernote) {
  var data;
  data = new FormData;
  data.append('upload[image]', file);
  return $.ajax({
    data: data,
    type: 'POST',
    url: '/uploads',
    cache: false,
    contentType: false,
    processData: false,
    success: function(data) {
      console.log('file uploading...');
      console.log(data);
      return toSummernote.summernote("insertImage", data.image_path.url);
    }
  });
};
  $('[data-provider="summernote"]').each(function() {
   $(this).summernote({
      height: 200,
       callbacks: {
        onImageUpload: function(files) {
          return sendFile(files[0], $(this));
        }
       }
    });
  });
});

var sendFile;

sendFile = function(file, toSummernote) {
  var data;
  data = new FormData;
  data.append('upload[image]', file);
  return $.ajax({
    data: data,
    type: 'POST',
    url: '/uploads',
    cache: false,
    contentType: false,
    processData: false,
    success: function(data) {
      console.log('file uploading...');
      return toSummernote.summernote("insertImage", data.url);
    }
  });
};

$(document).on('page:change', function(event) {
  $('[data-provider="summernote"]').each(function() {
    return $(this).summernote({
      lang: 'ko-KR',
      height: 500,
      codemirror: {
        lineWrapping: true,
        lineNumbers: true,
        tabSize: 2,
        theme: 'solarized'
      },
      callbacks: {
        onImageUpload: function(files) {
          return sendFile(files[0], $(this));
        }
      }
    });
  });
});
