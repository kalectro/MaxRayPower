raymovie = avifile('raymaker_test.avi');
raymovie.fps = 19;
raymovie.Compression = 'Cinepak';

for theta = 0:10:90
    for phi = -90:10:90
        raymaker(phi, theta);
        frame = getframe(gcf);
        raymovie = addframe(raymovie, frame);
    end
end
raymovie = close(raymovie);