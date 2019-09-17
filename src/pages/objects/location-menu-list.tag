| import 'components/datatable.tag'
| import 'pages/images/images-modal.tag'

location-menu-list
    catalog-static(name='{ opts.name }', cols='{ cols }', rows='{ value }', handlers='{ handlers }',
    upload='{ upload }', remove='false', reorder='true', sortable='{ sort }')
        #{'yield'}(to='toolbar')
            .form-group(if='{ checkPermission("images", "1000") }')
                button.btn.btn-primary(onclick='{ handlers.catalog }', type='button')
                    i.fa.fa-plus
                    |  Сбросить
        #{'yield'}(to='body')
            datatable-cell(name='')
                img(src!='{ handlers.rootImagePath + row.imagePath }', height='30px', width='30px')
            datatable-cell(name='') { row.name }
            datatable-cell(name='nameObject') { row.nameType } { row.nameObject }

    script(type='text/babel').
        var self = this
        self.mixin('permissions')
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

        self.cols = [
            {name: '', value: ''},
            {name: '', value: 'Заголовок'},
            {name: 'nameObject', value: 'Объект'},

        ]

        self.catalog = () => {
            API.request({
                object: 'Location',
                method: 'Items',
                data: { id: opts.id },
                success(response) {
                    //self.value = self.value.filter(item => {
                        //return false
                    //})
                    self.value = []
                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)
                    response.menu.forEach(function(item){
                        self.value.push(item)
                    })
                    self.update()
                }
            })
        }

        self.handlers = {
            rootImagePath: app.getImageUrl("/"),
            catalog: function() {
                self.catalog()
            }

        }

        self.sort = e => {
            console.log(e)
            return true;
        }

        self.on('update', () => {
            if ('name' in opts && opts.name !== '')
                self.root.name = opts.name

            if ('value' in opts)
                self.value = opts.value || []
        })