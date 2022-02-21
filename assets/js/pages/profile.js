
"use strict"

$(document).ready(function () {
    $("#mobile").keypress(function (e) {
        //if the letter is not digit then display error and don't type anything
        if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
            //display error message
            return false;
        }
    });

    var temp = get_details(user_id);

    $("#user_id").val(temp['data']['id']);
    $("#name").val(temp['data']['name']);
    $("#mobile").val(temp['data']['mobile']);
    $("#email").val(temp['data']['email']);
    $("#rank").html(temp['data']['all_time_rank']);
    $("#score").html(temp['data']['all_time_score']);
    $("#coins").html(temp['data']['coins']);
    if (temp['data']['profile'] != '') {
        $("#user_profile").attr("src", temp['data']['profile']);
    }

    $(".camera-icon").click(function (e) {
        $(".file-upload").click();
    });

    var data = {'get_users_statistics': '1', 'user_id': user_id};
    var result = get_apis_data(data);
    if (result['error'] == FALSE) {
        $('#stat_graph').show();
        var strong_category = '';
        var weak_category = '';
        var dataPoints;
        if (result['data'].strong_category == null) {
            strong_category = '<div class="progress-bar bg-success" role="progressbar" style="width: 0%;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">No data available (0%)</div>';
        } else {
            strong_category = '<div class="progress-bar bg-success" role="progressbar" style="width: ' + result['data'].ratio1 + '%;" aria-valuenow="' + result['data'].ratio1 + '" aria-valuemin="0" aria-valuemax="100">' + result['data'].strong_category + ' (' + result['data'].ratio1 + '%)</div>';
        }

        if (result['data'].weak_category == null) {
            weak_category = '<div class="progress-bar bg-danger" role="progressbar" style="width: 0%;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">No data available (0%)</div>';
        } else {
            weak_category = '<div class="progress-bar bg-danger" role="progressbar" style="width: ' + result['data'].ratio2 + '%;" aria-valuenow="' + result['data'].ratio2 + '" aria-valuemin="0" aria-valuemax="100">' + result['data'].weak_category + ' (' + result['data'].ratio2 + '%)</div>';
        }

        $("#attended_question").html(result['data'].questions_answered);
        $("#correct_answers").html(result['data'].correct_answers);
        $("#incorrect_answers").html(result['data'].questions_answered - result['data'].correct_answers);
        $("#strong_category").html(strong_category);
        $("#weak_category").html(weak_category);
        var attended = result['data'].questions_answered;
        var correct = result['data'].correct_answers;
        var incorrect = result['data'].questions_answered - result['data'].correct_answers;

        var correct_per = ((correct * 100) / attended);
        var incorrect_per = ((incorrect * 100) / attended);
        var c = (correct_per).toFixed(2);
        var i = (incorrect_per).toFixed(2);
        draw_graph(c, i);
    } else {
        $('#stat_graph').hide();
    }

    function draw_graph(correct_per, incorrect_per) {
        var canvas = document.getElementById("canvas");

        window.arcSpacing = 0.15;
        window.segmentHovered = false;

        Chart.elements.Arc.prototype.draw = function () {
            var ctx = this._chart.ctx;
            var vm = this._view;
            var sA = vm.startAngle;
            var eA = vm.endAngle;

            ctx.beginPath();
            ctx.arc(vm.x, vm.y, vm.outerRadius, sA + window.arcSpacing, eA - window.arcSpacing);
            ctx.strokeStyle = vm.backgroundColor;
            ctx.lineWidth = vm.borderWidth;
            ctx.lineCap = 'round';
            ctx.stroke();
            ctx.closePath();
        };

        var config = {
            type: 'doughnut',
            data: {
                labels: [correct_per, incorrect_per],
                datasets: [{
                        data: [correct_per, incorrect_per],
                        backgroundColor: ['#28a745', '#dc3545']
                    }]
            },
            options: {
                cutoutPercentage: 80,
                elements: {
                    arc: {borderWidth: 12}
                },
                legend: {display: true},
                tooltips: {
                    enabled: false,
                    custom: function (tooltip) {
                        if (tooltip.body) {
                            var line = tooltip.body[0].lines[0],
                                    parts = line.split(': ');//                                  
                            window.segmentHovered = true;
                        } else {
                            window.segmentHovered = false;
                        }
                    },
                },
            },
        };

        window.chart = new Chart(canvas, config);

        function addData(chart, label, data) {
            chart.data.labels.push(label);
            chart.data.datasets.forEach((dataset) => {
                dataset.data.push(data);
            });
            chart.update();
        }
    }

    function fasterPreview(uploader) {
        if (uploader.files && uploader.files[0]) {
            $('.profile-rounded').attr('src', window.URL.createObjectURL(uploader.files[0]));
            var fd = new FormData();
            var files = uploader.files[0];
            fd.append('image', files);
            fd.append('user_id', user_id);
            fd.append('access_key', '6808');
            fd.append('upload_profile_image', '1');
            $.ajax({
                url: QUIZ_URL,
                type: 'post',
                data: fd,
                contentType: false,
                processData: false,
                headers: {Authorization: 'Bearer ' + JWT_TOKEN},
                beforeSend: function () {
                    $('.profile-rounded').attr('src', 'assets/images/oppoloader.gif');
                },
                success: function (response) {
                    if (response['error'] == FALSE) {
                        $('#user_profile').attr('src', response['file_path']);
                        $('#result').html(response['message']);
                        $('#result').show().delay(4000).fadeOut();
                    } else {
                        $('#result').html(response['message']);
                    }
                }
            });
        }
    }
    $(".file-upload").change(function () {
        fasterPreview(this);
    });

    $('#user_update').on('submit', function (e) {
        e.preventDefault();
        var formData = new FormData(this);
        var name = formData.get('name');
        $.ajax({
            type: 'POST',
            url: QUIZ_URL,
            headers: {Authorization: 'Bearer ' + JWT_TOKEN},
            data: formData,
            beforeSend: function () {
                $('#submit_btn').html('Please wait..');
                $('#submit_btn').prop('disabled', true);
            },
            cache: false,
            contentType: false,
            processData: false,
            success: function (result) {
                $('#submit_btn').html('Update');
                $('#result').html(result['message']);
                $('#result').show().delay(6000).fadeOut();
                $('#submit_btn').prop('disabled', false);
                $.ajax({
                    type: "get",
                    url: "session_info.php",
                    dataTpe: 'json',
                    data: 'name=' + name + '&update=update',
                    success: function (data) {}
                });
                setTimeout(function () {
                    window.location.href = 'profile.php';
                }, 3000);
            }
        });
    });

});
