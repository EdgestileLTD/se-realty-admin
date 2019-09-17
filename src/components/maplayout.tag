maplayout
    img(src='{ opts.image }', id='{ name }')

    style.
        img#layoutImg {
            position: absolute;
        }


        svg {
            /*background: aliceblue;*/
            z-index: 100;
            position: absolute;
            top: 0;
            left: 15px;
        }

        polygon {
            fill: rgba(0, 0, 0, .2);
            stroke: #777;
        }

        g.active polygon {
            fill: rgba(0, 255, 0, .3);
            stroke: #090;
            z-index: 1000;
        }

        circle {
            r: 5;
            fill: rgba(0, 0, 0, .3);
            cursor: pointer;
        }

        circle.active {
            fill: green;
        }

        circle.first {
            fill: rgba(255, 0, 0, .3);
        }


    script(type='text/babel').
        var self = this
        self.items = []
        self.Coord = []
        self.it = 0
        self.$svg = null

        var circle = null,
        draw = false,
        $poly = null,
        c = {};


        self.addArea =(id, coords) => {
            var g = document.createElementNS('http://www.w3.org/2000/svg', 'g'),
            poly = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');

            var $g = $(g).attr('id', 'tt' + id).appendTo(self.$svg);

            $(poly).attr('points', coords).appendTo($g);
        }

        self.updateCoord = () =>{
            var ppoints = $poly.find('polygon').attr('points');
            if (!ppoints) return;
            var points = ppoints.split(',')
            self.items[self.it].coord = points
            //parent.update()
        }

        self.activeArea =(id) => {
            if (self.$svg !== null) {
                $poly = self.$svg.find('g#tt' + id);
                self.$svg.find('circle').remove();
                self.$svg.find('g').removeAttr('class');
                $poly.attr('class', 'active').appendTo(self.$svg);
                var ppoints = $poly.find('polygon').attr('points');
                if (!ppoints) return;
                var points = ppoints.split(',')

                if (points) {
                    var cx = 0, cy = 0;
                    for (var i = 0; i < points.length; i++) {
                        if (i % 2 == 0) {
                            cx = points[i];
                        }
                        else {
                            cy = points[i];
                            self.addPoint(cx, cy);
                        }
                    }
                }
            }
        }

        self.mouseCoord = (e) => {
            if (self.$svg !== null) {
                if (e) {
                    var offset = self.$svg.offset(),
                    x = (e.pageX - offset.left),
                    y = (e.pageY - offset.top),
                    c = {x: x, y: y}
                }
                return c;
            }
        }

        self.deletePoint = () => {
            $poly.find('circle.active').remove();
            $poly.find('circle').last().attr('class', 'active');
            self.drawPoly();
        }

        self.addPoint = (x, y) => {
            var cir = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
            $('circle').removeAttr('class');
            $(cir).appendTo($poly).attr('cx', x).attr('cy', y).attr('class', 'active');
            self.drawPoly();
        }

        self.drawPoly =()=> {
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
            self.updateCoord();
        }

        self.setPoints = () => {
            var find = false;

            $poly.find('circle').each(function () {
                $(this).appendTo($poly);
                if ($(this).is('.active')) {
                    return false;
                }
            });
        }

        self.moveRect = e => {
            if (e.keyCode == 46)
                self.deletePoint();
        }

        self.execute = () => {

            $('g').off().on('mousedown', 'circle', function (e) {
                e.stopPropagation();

                if (!$(this).closest($poly).length)
                    return false;

                $('circle').removeAttr('class');

                circle = $(this).attr('class', 'active');

                self.setPoints();
                draw = true;
                return false;
            })

            $('g').on('mouseup', 'circle', function (e) {
                e.stopPropagation();
                draw = false;
                circle = null;
                return false;
            })


            if (self.$svg !== null) {
                self.$svg.off().mousemove(function (e) {
                    e.stopPropagation();
                    if (draw && circle) {
                        circle.attr('cx', self.mouseCoord(e).x).attr('cy', self.mouseCoord(e).y);
                        self.drawPoly();
                    }
                    return false;
                })

                self.$svg.mouseup(function (e) {
                    if (!circle && $poly) {
                        self.addPoint(self.mouseCoord(e).x, self.mouseCoord(e).y);
                    }
                });
            }
        }

        observable.on('maplayout-update', (it) => {
            self.it = it
            self.activeArea(self.it);
            addEventListener("keydown", self.moveRect);
            self.execute();
        })

        self.on('update', () => {
            $('svg').remove()
            self.name = ('name' in opts) ? opts.name : layoutImg
            //console.log(opts.items)
            if ('items' in opts) {
                self.items = opts.items
                if ('image' in opts && opts.image) {
                    self.update()
                    var $img  = $('img#' + self.name)

                    var svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg'),
                    width = $img.width(),
                    height = $img.height();

                    self.$svg = $(svg).attr({'width': width, 'height': height}).insertAfter($img);

                        //self.init($('#' + self.name))
                    if (self.items.length > 0) {
                        for (var i = 0; i < self.items.length; i++) {
                            self.items[i].coord = (self.items[i].coord) ? self.items[i].coord : [];
                            self.addArea(i, self.items[i].coord);
                        }
                        self.activeArea(self.it);
                        addEventListener("keydown", self.moveRect);
                        self.execute();
                    }
                }
            }
        })

        self.on('mount', () => {
            self.name = ('name' in opts) ? opts.name : layoutImg
            self.items = ('items' in opts) ? opts.items : []
            self.it = ('it' in opts) ? opts.it : 0
        })
