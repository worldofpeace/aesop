namespace Aesop {
public class Viewer: Gtk.Application {
    public void render_page() {
        var settings = AppSettings.get_default ();

        // document
        Poppler.Document document = null;
        
        try {
            document = new Poppler.Document.from_file(Filename.to_uri(filename), "");
        } catch(Error e) {
            error ("%s", e.message);
        }

        total = document.get_n_pages();

        // page size
        double page_width;
        double page_height;
        var pages = document.get_page(page_count - 1);
        pages.get_size(out page_width, out page_height);

        // image size
        int width  = (int)(settings.zoom * page_width) ;
        int height = (int)(settings.zoom * page_height);

        // render page to cairo context
        var surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, width, height);
        var context = new Cairo.Context(surface);
        context.scale(settings.zoom, settings.zoom);
        pages.render(context);

        // get pixbuf from surface
        Gdk.Pixbuf pixbuf = Gdk.pixbuf_get_from_surface(surface, 0, 0, width, height);

        // set title
        window.set_title(("Aesop - %s (%d/%d)").printf(GLib.Path.get_basename(filename), page_count,
                                               total));

        // image from pixbuf
        image.set_from_pixbuf(pixbuf);

        // move scrollbar's adjustment
        page.get_vadjustment().set_value(0);

        // save
        settings.last_file = filename;
        settings.last_page = page_count;
    }
}
}