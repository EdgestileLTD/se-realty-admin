/*
 var items = [
 { id: 1, idMap:2, coord:[780,265,629,371,530,154,641,69], idItem: 134, title:'text1'},
 { id: 2, idMap:4, coord:[50,50,100,50,20,120], idItem: 130, title:'text2'},
 { id: 3, idMap:4, coord:[100,100,200,100,150,200], idItem: 130, title:'text2'},
 { id: 4, idMap:4, coord:[200,200,300,200,250,280], idItem: 130, title:'text2'}
 ];
 */
var circle = null,
    draw = false,
    $poly = null,
    $svg = null,
    c = {};

function init(img) {
    var svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
    width = $(img).width(),
        height = $(img).height();

    $svg = $(svg).attr({'width': width, 'height': height}).insertAfter(img);
}

function addArea(id, coords) {
    var g = document.createElementNS('http://www.w3.org/2000/svg', 'g'),
        poly = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');

    var $g = $(g).attr('id', 'tt' + id).appendTo($svg);

    $(poly).attr('points', coords).appendTo($g);

}

function activeArea(id) {
    if ($svg !== null) {
        $poly = $svg.find('g#tt' + id);

        $svg.find('circle').remove();

        $svg.find('g').removeAttr('class');

        $poly.attr('class', 'active').appendTo($svg);

        var points = $poly.find('polygon').attr('points').split(',');
        if (points) {
            var cx = 0, cy = 0;
            for (var i = 0; i < points.length; i++) {
                if (i % 2 == 0) {
                    cx = points[i];
                }
                else {
                    cy = points[i];
                    addPoint(cx, cy);
                }
            }
        }
    }
}

function mouseCoord(e) {
    if ($svg !== null) {
        if (e) {
            var offset = $svg.offset();
            x = (e.pageX - offset.left);
            y = (e.pageY - offset.top);
            c = {x: x, y: y}
        }
        return c;
    }
}

function deletePoint() {
    $poly.find('circle.active').remove();
    $poly.find('circle').last().attr('class', 'active');
    drawPoly();
}

function addPoint(x, y) {
    var cir = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    $('circle').removeAttr('class');
    $(cir).appendTo($poly).attr('cx', x).attr('cy', y).attr('class', 'active');
    drawPoly();
}

function drawPoly() {
    var coord = [],
        end = [];

    $poly.find('circle.active');
    $poly.find('circle').each(function () {
        var x = $(this).attr('cx'),
            y = $(this).attr('cy');

        coord.push(x);
        coord.push(y);
    })
    $poly.find('polygon').attr('points', coord.join());
}

function setPoints() {
    var find = false;

    $poly.find('circle').each(function () {
        $(this).appendTo($poly);
        if ($(this).is('.active')) {
            return false;
        }
    });
}

$('g').off().on('mousedown', 'circle', function (e) {
    e.stopPropagation();

    if (!$(this).closest($poly).length)
        return false;

    $('circle').removeAttr('class');

    circle = $(this).attr('class', 'active');

    setPoints();

    draw = true;
    return false;
})

$('g').on('mouseup', 'circle', function (e) {
    e.stopPropagation();
    draw = false;
    circle = null;
    return false;
})

function execute() {
    if ($svg !== null) {
        $svg.off().mousemove(function (e) {
            e.stopPropagation();
            if (draw && circle) {
                circle.attr('cx', mouseCoord(e).x).attr('cy', mouseCoord(e).y);
                drawPoly();
            }
            return false;
        })

        $svg.mouseup(function (e) {
            if (!circle && $poly) {
                addPoint(mouseCoord(e).x, mouseCoord(e).y);
            }
        });
    }
}

function moveRect(e) {
    if (e.keyCode == 46)
        deletePoint();
}
/*

 var pmaps = function(imgPath, items, id) {
 init(imgPath);
 for (var i = 0; i < items.length; i++) {
 addArea(items[i].id, items[i].coord);
 }
 activeArea(id);
 addEventListener("keydown", moveRect);
 }
 */