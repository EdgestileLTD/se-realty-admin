| import 'components/catalog-static.tag'


object-related-list
    catalog-static(name='{ opts.name }', rows='{ value }',
    cols='{ cols }',
    add='{ add }',
    remove='true', dblclick='{ objectOpen }')
        #{'yield'}(to='body')
            datatable-cell(name='id', style='width: 5%') { row.id }
            datatable-cell(name='imageUrlPreview', style='width: 10%')
                img(src='{ row.imageUrlPreview }', alt='', width='60')
            datatable-cell(name='typeName', style='width: 20%') { row.typeName }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='isMain', style='width: 2%') { row.isMain ? 'Да' : 'Нет' }
    style.
        datatable-head-cell[name=id] {
            width: 50px;
        }
        datatable-head-cell[name=imageFile] {
            width: 50px;
        }
        datatable-head-cell[name=date] {
            width: 100px;
        }



    script(type='text/babel').
        var self = this
        self.id = 0
        self.cols = [
            { name: 'id', value: '#'},
            { name: 'imageUrlPreview', value: ''},
            { name: 'typeName', value: 'Тип'},
            { name: 'name', value: 'Наименование'},
            { name: 'isMain', value: 'Главный'},
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

        self.add = () => {
            modals.create('object-list-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    self.related = self.related || []
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()
                    let ids = self.related.map(item => {
                        return item.id
                    })
                    items.forEach(function (item) {
                        if (ids.indexOf(item.id) === -1) {
                            item.idRelated = item.id
                            item.id = null
                            self.value.push(item)
                        }
                    })
                    self.update()
                    this.modalHide()
                }
            })
        }


        self.objectOpen = e => riot.route(`/objects/${e.item.row.idRelated}`)

        self.on('update', () => {
            if ('name' in opts && opts.name !== '')
                self.root.name = opts.name

            if ('value' in opts)
                self.value = opts.value || []
        })


