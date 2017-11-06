# README #

### There are 2 screen: ###

### 1. ListViewController: ###
*  Displaying a list videos downloaed and parse from JSON

*  Click a cell to go to Detail info of this video. However, if video is unable to play(ex: no network, no url, ...)., the application will display a alert to notify that you are ubable to open this video

### 2. DetailViewController: ###

*  DetailViewController is the heart of this application. This viewcontroller are able to:
        *  Play video
        *  Pause
        *  Seek to specific time
        *  Loop one, loop forever
        *  Download
        *  Delete a file if it downloaded
        
*  If it has no network, this viewcontroller will detect whether existed any local file and play it.

*  If a local file existed, when you click download button, instead of downloading a file, this viewcontroller will show an alert to ask you want to delete that local file. You can choose "Cancel" or "OK". If you choose OK, the application will delete file immediately, and force user out of screen, back to ListViewController.

*  If no local file existed, when you click download button, application will display a progress view to display the percentage dowloading. When downloading successfully, the progress view will be hidden, and a label will appear with content "Download successfully" or display a error.
    
