// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import HelloController from "controllers/hello_controller"
import CarouselController from "controllers/carousel_controller"

application.register("hello", HelloController)
application.register("carousel", CarouselController)
