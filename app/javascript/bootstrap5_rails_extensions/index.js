import ModalController from "./modal_controller"
import OffcanvasController from "./offcanvas_controller"
import ToastController from "./toast_controller"

const defaultControllers = {
  modal: ModalController,
  offcanvas: OffcanvasController,
  toast: ToastController,
}

// Stimulusアプリケーションへ本Gemのコントローラーをまとめて登録する
export function registerBootstrap5Controllers(application, controllers = {}) {
  if (!application) {
    throw new Error("Stimulusアプリケーションが未指定です。")
  }

  const registrationMap = { ...defaultControllers, ...controllers }

  Object.entries(registrationMap).forEach(([identifier, controller]) => {
    const alreadyRegistered = application.router?.modulesByIdentifier?.has?.(identifier)
    if (alreadyRegistered) return

    application.register(identifier, controller)
  })
}

export { ModalController, OffcanvasController, ToastController }
