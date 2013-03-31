#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#define NSMakeSquareSize(dim) NSMakeSize((dim), (dim))

void create_images(NSString *path)
{
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
    
    if(!image)
	{
		NSLog(@"Could not find specified image.");
		return;
	}
	
	if(image.size.width != 1024 || image.size.height != 1024)
		NSLog(@"Expected origin image dimensions of 1024x1024 pixels. (%.2f, %.2f) Generated icons may be distorted.", image.size.width, image.size.height);
    
    /*
     sips --resampleWidth 57 "${f}/${1}" --out "${f}/Icon.png"
     sips --resampleWidth 114 "${f}/${1}" --out "${f}/Icon@2x.png"
     sips --resampleWidth 29 "${f}/${1}" --out "${f}/Icon-Small.png"
     sips --resampleWidth 58 "${f}/${1}" --out "${f}/Icon-Small@2x.png"
     sips --resampleWidth 50 "${f}/${1}" --out "${f}/Icon-Small-50.png"
     sips --resampleWidth 100 "${f}/${1}" --out "${f}/Icon-Small-50@2x.png"
     sips --resampleWidth 72 "${f}/${1}" --out "${f}/Icon-72.png"
     sips --resampleWidth 144 "${f}/${1}" --out "${f}/Icon-72@2x.png"
     sips --resampleWidth 512 "${f}/${1}" --out "${f}/iTunesArtwork"
     sips --resampleWidth 1024 "${f}/${1}" --out "${f}/iTunesArtwork@2x"
     */
    
	CGFloat sizes[] = {
        57, 114,
        29, 58,
        50, 100,
        72, 144,
        512, 1024,
        0 };
    
	NSString *sizeNames[] = {
        @"Icon.png", @"Icon@2x.png",
        @"Icon-Small.png", @"Icon-Small@2x.png",
        @"Icon-Small-50.png", @"Icon-Small-50@2x.png",
        @"Icon-72.png", @"Icon-72@2x.png",
        @"iTunesArtwork", @"iTunesArtwork@2x"};
    
    //	NSString *prefixPath = [path stringByDeletingPathExtension];
	NSSize originalSize = [image size];
	
	CGFloat *size = sizes;
	int idx = 0;
	while(*size)
	{
        //		NSString *resizedPath = [NSString stringWithFormat:@"%@-%d.png", prefixPath, (int)*size];
        NSMutableArray *pathComponents = [[path pathComponents] mutableCopy];
        [pathComponents removeLastObject];
        [pathComponents addObject:sizeNames[idx++]];
		NSString *resizedPath = [NSString pathWithComponents:pathComponents];
		NSSize resizedSize = NSMakeSquareSize(*size/2);
        
        NSImage *resizedImage = [[NSImage alloc] initWithSize:resizedSize];
        
        NSLog(@"Making image %.2f x %.2f", resizedSize.width, resizedSize.height);
        
		if(resizedImage){
			[resizedImage lockFocus];
            [NSGraphicsContext saveGraphicsState];
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
            [[NSGraphicsContext currentContext] setShouldAntialias:YES];
            
			[image drawInRect:NSMakeRect(0, 0, resizedSize.width, resizedSize.height)
                     fromRect:NSMakeRect(0, 0, originalSize.width, originalSize.height)
                    operation:NSCompositeSourceOver
                     fraction:1.0];
            [NSGraphicsContext restoreGraphicsState];
			[resizedImage unlockFocus];
            
			NSBitmapImageRep *bits = [[NSBitmapImageRep alloc] initWithCGImage:[resizedImage CGImageForProposedRect:NULL context:NULL hints:NULL]];
			NSData *data = [bits representationUsingType: NSPNGFileType properties: nil];
			[data writeToFile: resizedPath atomically: NO];
			
			[bits release];	
		}
        
        [resizedImage release];
        
		++size;
	}
	
	[image release];
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	if(argc < 2)
	{
		NSLog(@"Usage: iosicons <filename>");
		return -1;
	}
	
	NSMutableArray *args = [NSMutableArray arrayWithCapacity:argc];
	for(int i = 0; i < argc; ++i)
		[args addObject:[[NSString alloc] initWithBytes:argv[i] length:strlen(argv[i]) encoding:NSASCIIStringEncoding]];
	
	create_images([args objectAtIndex:1]);
    
    [pool drain];
    return 0;
}
