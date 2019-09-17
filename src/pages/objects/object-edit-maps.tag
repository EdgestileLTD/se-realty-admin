| import 'components/datatable.tag'
| import 'pages/images/images-modal.tag'

object-edit-maps
    .row
        .col-md-12
            catalog-static(name='{ opts.name }', add='{ add }', dblclick='{ open }',
            cols='{ cols }', rows='{ value }', handlers='{ handlers }', remove='true')
                #{'yield'}(to='toolbar')
                    .dropdown(if='{ selectedCount > 0 }', style='display: inline-block;')
                        button.btn.btn-default.dropdown-toggle(data-toggle="dropdown", aria-haspopup="true", type='button', aria-expanded="true")
                            | Действия&nbsp;
                            span.caret
                        ul.dropdown-menu
                            li(onclick='{ handlers.cloneMaps }', class='{ disabled: selectedCount > 1 }')
                                a(href='#')
                                    i.fa.fa-fw.fa-clone
                                    |  Клонирование


                #{'yield'}(to='body')
                    datatable-cell(name='mapImage', style="width: 220px;")
                        img(src!='{ handlers.rootImagePath + row.imagePath }', width='200px')
                    datatable-cell(name='')
                        .col.md-12
                            .col-md-3(each='{ var in row.features }')
                                .form-group
                                    label.control-label { var.name }
                                    span.form-control(style='width: 80px;') { var.value }
                    datatable-cell(name='mapCount', style="width: 50px;") { row.mapCount }



    script(type='text/babel').
        var self = this
        self.app = app

        self.cols = [
            {name: 'mapImage', value: 'План'},
            {name: 'title', value: 'Наименование'},
            {name: 'mapCount', value: 'Объектов'},
        ]

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value
            },
            set(value) {
                self.value = value || []
                self.update()
            }
        })

        self.handlers = {
            rootImagePath: app.getImageUrl("/"),
            cloneMaps(e){
                var _this = this
                e.stopPropagation()
                e.stopImmediatePropagation()
                let item = this.tags.datatable.getSelectedRows()
                self.value.push({
                    imagePath: item[0].imagePath
                })
                observable.trigger('object-save')
            },
        }

        self.open = e => {
           // console.log(e)
            riot.route(`/objects/maps/${e.item.row.id}`)
        }

        self.add = e => {
            modals.create('images-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit: function () {
                    let imagemanager = this.tags.imagemanager
                    let items = imagemanager.getSelectedFiles()
                    let path = imagemanager.path

                    items.forEach(item => {
                        self.value.push({
                            imagePath: app.clearRelativeLink(`${path}/${item.name}`)
                        })
                    })
                    observable.trigger('object-save')

                    //let event = document.createEvent('Event')
                    //event.initEvent('change', true, true)
                    //self.root.dispatchEvent(event)
                    //observable.trigger('object-save')
                    self.update()
                    this.modalHide()
                }
            })
        }

        self.on('update', () => {
            if ('name' in opts && opts.name !== '')
                self.root.name = opts.name

            if ('value' in opts)
                self.value = opts.value || []
        })

