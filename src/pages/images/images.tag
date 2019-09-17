| import 'components/imagemanager.tag'

images
    imagemanager(value='{ value }')

    script(type='text/babel').
        var self = this,
            route = riot.route.create()

        route('images', () => {
            self.tags.imagemanager.reload()
        })

        self.on('mount', () => {
            riot.route.exec()
        })