| import 'components/datatable.tag'
| import 'pages/prices/prices-categories-list.tag'
| import 'pages/files/files-modal.tag'
//| import 'pages/images/images-gallery-modal.tag'


prices-files
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li.active: a(data-toggle='tab', href='#object-doc-list') Документы
        li: a(data-toggle='tab', href='#object-doc-cat') Категории

    .tab-content
        #object-doc-list.tab-pane.fade.in.active
            .row
                .col-md-12
                    catalog(object='Price', name='{ opts.name }', cols='{ cols }', rows='{ items }', handlers='{ handlers }',
                    add='{ catalog }', upload='{ upload }', remove='{ remove }', reload='true', reorder='true')
                        #{'yield'}(to='toolbar')
                            .form-group(if='{ checkPermission("images", "1000") }')
                                button.btn.btn-primary(onclick='{ opts.catalog }', type='button')
                                    i.fa.fa-plus
                                    |  Добавить
                        #{'yield'}(to='body')
                            datatable-cell(name='', style='width: 30px;')
                                i.fa.fa-cloud-download.fa-2x
                            datatable-cell(name='')
                                input.form-control(value='{ row.name }', onchange='{ handlers.fileNameChange }')
                            datatable-cell(name='')
                                b.form-control-static { row.filePath }
                            datatable-cell(name='')
                                b.form-control-static
                                    select.form-control(name='type', onchange='{ handlers.changeType }')
                                        option(value='0', selected='{ 0 == row.type }', no-reorder) Прайс
                                        option(value='1', selected='{ 1 == row.type }', no-reorder) Документ
                            datatable-cell(name='')
                                b.form-control-static
                                    select.form-control(name='idGroup', onchange='{ handlers.changeCategory }')
                                        option(value='') Без категории
                                        option(each='{ handlers.filesCategory }', value='{ id }',
                                        selected='{ id == row.idGroup }', no-reorder) { name }
        #object-doc-cat.tab-pane.fade
            .row
                .col-md-12
                    prices-categories-list(idObject='{ idObject }')

    script(type='text/babel').
        var self = this
        self.collection = 'Price'
        self.filesCategory = []
        self.idObject = 0

        self.mixin('permissions')
        self.mixin('remove')
        self.app = app

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value
            },
            set(value) {
                self.value = value || []
                self.update()
            }
        })

        self.add = () => {}

        self.cols = [
            {name: '', value: ''},
            {name: '', value: 'Текст ссылки'},
            {name: '', value: 'Файл'},
            {name: '', value: 'Раздел'},
            {name: '', value: 'Категория'},
        ]

        self.handlers = {
            fileNameChange: function (e) {
                e.item.row.name = e.target.value
                self.save(e.item.row)
            },
            changeCategory: function(e) {
                if (e.target.value == '')
                    e.item.row.idGroup = null
                else e.item.row.idGroup = e.target.value

                self.save(e.item.row)
            },
            changeType: function(e) {
                e.item.row.type = e.target.value

                self.save(e.item.row)
            },

            filesCategory: []
        }

        self.getCategoryes = () => {
            API.request({
                object: 'PricesCategory',
                method: 'Fetch',
                success(response) {
                    self.handlers.filesCategory = response.items
                    self.update()
                }
            })
        }

        self.catalog = e => {
            modals.create('files-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit: function () {
                    let filemanager = this.tags.filemanager
                    let items = filemanager.getSelectedFiles()
                    let path = filemanager.path
                    let name = filemanager.name

                    items.forEach(item => {
                        self.save({
                        filePath: app.clearRelativeLink(`${path}/${item.name}`),
                        name: name
                        });
                    })
                    self.update()
                    self.tags.catalog.reload()
                    this.modalHide()
                }
            })
        }

        self.one('updated', () => {
            self.tags.catalog.tags.datatable.on('reorder-end', () => {
                let {current, limit} = self.tags.catalog.pages
                let params = { indexes: [] }
                let offset = current > 0 ? (current - 1) * limit : 0

                self.tags.catalog.items.forEach((item, sort) => {
                    item.sort = sort + offset
                    params.indexes.push({id: item.id, sort: item.sort})
                })

                console.log(params)

                API.request({
                    object: 'Price',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })

                self.update()
            })
        })

        self.on('update', () => {
            if ('name' in opts && opts.name !== '')
                self.root.name = opts.name

        })

        self.save = (items) => {
            API.request({
                object: 'Price',
                method: 'Save',
                data: items,
                success(response) {
                    self.loader = false
                    self.tags.catalog.items = response.items
                    self.update()
                }
            })
        }


        self.on('mount', () => {
            self.getCategoryes()
           // self.getPrice()
        })