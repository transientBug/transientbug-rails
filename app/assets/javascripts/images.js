$(".message .close")
  .on("click", function() {
    $(this)
      .closest(".message")
      .transition("fade");
  });

$("#tags-input").dropdown();
