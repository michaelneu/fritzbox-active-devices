# FRITZ!Box active devices

Check which devices are connected to your FRITZ!Box via a macOS menu bar app.

## Configuration

If your FRITZ!Box is reachable under a different ip address than `192.168.178.1`, modify [AppDelegate.swift](https://github.com/michaelneu/fritzbox-active-devices/blob/25ce247daf0c3a3756d150458067e36a7a99b863/FritzBoxActiveDevices/AppDelegate.swift#L24) to fit your needs.

## Building

As this project requires Cocoapods, make sure to `pod install` and open the `.xcworkspace` file, or Xcode won't be able to build the project.

## How does it work?

This app uses the FRITZ!Box's SOAP UPnP interface, leveraging the `hosts` endpoint. See [TR-064 Support - Hosts](https://avm.de/fileadmin/user_upload/Global/Service/Schnittstellen/hostsSCPD.pdf) by AVM for more information.

## License

The code in this repository is released under the [MIT license](LICENSE).
