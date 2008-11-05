
var REPORT_REGEXP  = /^report_(\d+)$/;
var AJAX_INTERVAL  = 30000; // 15 seconds
var QUEUE_INTERVAL = 1000;  // 1 seconds
var ITEMS_TO_POP   = 1;     // pop off 1 items from the queue every 1 seconds.

// There is no code to handle a queue that is growing completely out of control

var max_report_id = -1;

// Set up reload call
function reloadReportData() {
  //console.log("reloadReportData();")
  $('#hdn_reports_container').load("/cached_reports.html");
  var local_queue = [];
  var local_max   = max_report_id;
  $('#hdn_reports_container').find('div').each(function(i) {
    //console.log("checking " + this.id);
    var id = parseInt(this.id.match(REPORT_REGEXP)[1]);
    if (id > local_max) {
      // Update the max if necessary
      local_max = id;
    }
    if (id > max_report_id) {
      // push it onto the local queue, which we'll sort afterwards
      local_queue.push(this);
      //console.log("pushing " + this.id + " onto local_queue.")
    }
  });
  // clear out our temp storage
  $('#hdn_reports_container').html("");
  jQuery.each(local_queue, function(index, value) {
    reports_queue.push(value);
    //console.log("pushing item w/ id " + value.id);
  });
  max_report_id = local_max;
}
setInterval("reloadReportData();", AJAX_INTERVAL);

var reports_queue = [];
function popReports() {
  for (var i = 0; i <= 1 && reports_queue.length >= ITEMS_TO_POP; i++) {
    var div = reports_queue.pop();
    div.style.display = 'none';
    insertReport(div);
    $(div).show("slow");
  }
}
setInterval("popReports();", QUEUE_INTERVAL);

function insertReport(report_div) {
  $('#reports').prepend(report_div);
}

$(document).ready(function() {
  var divs = $('#reports > div:first');
  if (divs.length == 1) {
    max_report_id = parseInt(divs[0].id.match(REPORT_REGEXP)[1]);
  }
});