add_executable(prog)
target_sources(prog PRIVATE 
    main.cpp
    )
target_link_libraries(prog PRIVATE spdlog::spdlog)
