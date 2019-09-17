| import 'components/datatable.tag'
| import 'pages/images/images-modal.tag'

news-images
    .row
        .col-md-12
            catalog-static(name='{ opts.name }', cols='{ cols }', rows='{ value }', handlers='{ handlers }',
            catalog='{ catalog }', upload='{ upload }', remove='true', reorder='true', sortable='{ sort }')
                #{'yield'}(to='toolbar')
                    .form-group(if='{ checkPermission("images", "1000") }')
                        button.btn.btn-primary(onclick='{ opts.catalog }', type='button')
                            i.fa.fa-plus
                            |  Добавить
                #{'yield'}(to='body')
                    datatable-cell(name='', style='width: 180px')
                        img(src!='{ handlers.rootImagePath + row.imagePath }', height='150px', width='150px')
                    datatable-cell(name='')
                        p.form-control-static { row.imagePath }
                        input.form-control(value='{ row.alt }', onchange='{ handlers.imageAltChange }')









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

        self.add = () => {}

        self.cols = [
            {name: '', value: 'Изображение'},
            {name: '', value: 'Алтернативная ссылка'},
        ]

        self.handlers = {
            imageAltChange: function (e) {
                e.item.row.alt = e.target.value
            },
            isMainChange: function (e) {
                for(var i=0; i<self.value.length; i++){
                    self.value[i].isMain = 0;
                }
                e.item.row.isMain = 1
                console.log(self.value)
                self.update()
            },
            rootImagePath: app.getImageUrl("/")
        }

        self.sort = e => {
            console.log(e)
            return true;
        }

        self.catalog = e => {
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

                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)

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