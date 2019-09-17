| import 'components/loader.tag'
| import 'components/autocomplete.tag'
| import 'components/maplayout.tag'
| import 'lodash/lodash'
| import 'lodash/lodash'

object-map-edit
    loader(if='{ loader }')
    div
        .btn-group
            a.btn.btn-default(href='#objects/{ idObject }') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isMulti }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 Редактирование планировки
        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-2(each='{ row, ii in item.features }')
                    .form-group(class='{ has-error: error.name }')
                        label.control-label { row.name }
                        input.form-control(if='{ row.type=="number" }', name='value', type='number', value='{ row.value }')
                        input.form-control(if='{ row.type=="string" }', name='value', type='text', value='{ row.value }')
                        autocomplete(if='{ row.type == "list" }', name='{ ii }', load-data='{ getOptions(row.idFeature) }',
                        value='{ row.idValue }', data-item='{ ii }', value-field='value', id-field='id', onchange='{ changeListValue }')
                            | { item.value }
            //, onchange='{ changeListValue }'




            .row
                .col-md-12
                    catalog-static(name='LayoutItem', rows='{ item.layouts }', cols='{ LayoutCols }', handlers='{ handlers }')
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='idItem', onclick='{ handlers.click }') { row.idItem }
                            datatable-cell(name='title', onclick='{ handlers.click }') { row.title }
                            datatable-cell(name='coord', onclick='{ handlers.click }') { row.coord }
                        // { LayoutRemove }

            .row
                .col-md-12
                    .form-inline.m-t-3.m-b-2
                        .form-group
                            .btn-group
                                button.btn.btn-default(onclick='{ changeImage }', type='button')
                                    i.fa.fa-floppy-o
                                    |  Выбрать другую карту
                        .form-group
                            label.control-label Выбранный слой { it }

            .row
                .col-md-12
                    .alert.alert-info
                        i.fa.fa-info
                        |  Выберите в списке объект и с помощью мышки укажите границы объекта на плане.
                        |  Для перемещения точки удерживайте ее нажатием мышки и перемещайте. Убрать точку - клавиша DEL.

            .row
                .col-md-12
                    maplayout(name='layoutImg', style='margin-bottom: 20px;', image='{ item.imageFull }', items='{ item.layouts }', it='{ it }')
                    //img(id='layoutImg', src='{ item.imageFull }')

    script(type='text/babel').
        var self = this
        self.idObject = 0
        self.id = 0
        self.items = []
        self.layoutId = 0
        self.it = 0
        self.clone = []

        //self.mixin('change')

        self.LayoutCols = [
            {name: 'id', value: '#'},
            {name: 'idItem', value: 'Объект'},
            {name: 'title', value: 'Заголовок'},
            {name: 'coord', value: 'Координаты'},
        ]

        self.handlers = {
            click : function(e) {
                self.it = e.item.row.it
                observable.trigger('maplayout-update', self.it)
                self.update()
                //console.log(e)
            }
        }



        observable.on('object-map-edit', id => {
            self.error = false
            self.id = id
            self.loader = true
            self.update()

            getMap(id)
        })

        self.getOptions = id => {
            var id = id
            return function () {
                var _this = this
                return API.request({
                    object: 'FeatureValue',
                    method: 'Fetch',
                    data: {filters: {field: 'idFeature', value: id}},
                    success(response) {
                        _this.data = response.items
                        if (!_this.isOpen) {
                            _this.data.forEach(item => {
                                if (item[_this.idField] == _this.opts.value) {
                                    _this.filterValue = item[_this.valueField]
                                }
                            })
                        }
                        _this.update()
                    }
                })
            }
        }
        self.changeListValue = e => {
            self.item.features[e.target.name].idValue = e.target.value
        }

        function getMap(id)
        {
            var data = {
                id: id
            }
            API.request({
                object: 'Layout',
                method: 'Info',
                data: data,
                success(response) {
                    self.item = response
                    self.idObject = response.idObject
                    self.loader = false
                    self.update()
                },
                error(response) {
                    self.item = {}
                }
            })
        }



        self.changeImage = e => {
            modals.create('images-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit: function () {
                    let imagemanager = this.tags.imagemanager
                    let items = imagemanager.getSelectedFiles()
                    let path = imagemanager.path
                    items.forEach(item => {
                        self.item.imageFull = item.url
                        self.item.imagePath = app.clearRelativeLink(`${path}/${item.name}`)
                        self.item.idImage = 0
                    })
                    self.update()
                    //self.layoutMaps()
                    this.modalHide()
                }
            })
        }

        self.addObject = e => {
            var item = {
                idMap: self.id,
                coord: '10,10,100,100,200,200',
            }
            self.items.push(item)
            self.layoutMaps()
        }

        self.submit = () => {
            var data = {
                idObject : self.idObject,
                features: self.item.features,
                isClone: self.clone
            }
            API.request({
                object: 'Layout',
                method: 'Save',
                data: self.item,
                success(response) {
                    self.item = response
                    self.idObject = response.idObject
                    popups.create({title: 'Успех!', text: 'Сохранено!', style: 'popup-success'})
                   // self.update()
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })

        }

        self.on('mount', () => {
            riot.route.exec()
        })